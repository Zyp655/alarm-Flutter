import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart';
import 'package:backend/database/database.dart';
import 'package:backend/helpers/env_helper.dart';
import 'package:backend/helpers/log.dart';

class EmbeddingService {
  final String openaiApiKey;
  final AppDatabase db;

  EmbeddingService({required this.openaiApiKey, required this.db});

  Future<List<double>> generateEmbedding(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return [];

    final input = trimmed.length > 8000
        ? trimmed.substring(0, 8000)
        : trimmed;

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/embeddings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openaiApiKey',
      },
      body: jsonEncode({
        'model': 'text-embedding-3-small',
        'input': input,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Embedding API Error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final embedding = (data['data'] as List)[0]['embedding'] as List;
    return embedding.cast<double>();
  }

  String _vectorToSql(List<double> vec) {
    return '[${vec.join(',')}]';
  }

  Future<int> embedCourse(int courseId) async {
    final course = await (db.select(db.courses)
          ..where((c) => c.id.equals(courseId)))
        .getSingleOrNull();
    if (course == null) return 0;

    final text = [
      course.title,
      course.description ?? '',
      course.tags ?? '',
    ].where((s) => s.isNotEmpty).join('. ');

    if (text.trim().length < 5) return 0;

    final vec = await generateEmbedding(text);
    if (vec.isEmpty) return 0;

    await db.customStatement(
      'UPDATE courses SET embedding = \'${_vectorToSql(vec)}\'::vector WHERE id = $courseId',
    );
    return 1;
  }

  Future<int> embedLesson(int lessonId) async {
    final lesson = await (db.select(db.lessons)
          ..where((l) => l.id.equals(lessonId)))
        .getSingleOrNull();
    if (lesson == null) return 0;

    final content = lesson.cachedTranscript ?? lesson.textContent ?? '';
    final text = [
      lesson.title,
      content.length > 6000 ? content.substring(0, 6000) : content,
    ].where((s) => s.isNotEmpty).join('. ');

    if (text.trim().length < 5) return 0;

    final vec = await generateEmbedding(text);
    if (vec.isEmpty) return 0;

    await db.customStatement(
      'UPDATE lessons SET embedding = \'${_vectorToSql(vec)}\'::vector WHERE id = $lessonId',
    );
    return 1;
  }

  Future<int> embedVideoSegment(int segmentId) async {
    final rows = await db.customSelect(
      'SELECT id, transcript, summary FROM video_segments WHERE id = \$1',
      variables: [Variable.withInt(segmentId)],
    ).get();
    if (rows.isEmpty) return 0;

    final row = rows.first;
    final transcript = row.read<String>('transcript');
    final summary = row.readNullable<String>('summary') ?? '';

    final text = [summary, transcript]
        .where((s) => s.isNotEmpty)
        .join('. ');

    if (text.trim().length < 5) return 0;

    final vec = await generateEmbedding(text);
    if (vec.isEmpty) return 0;

    await db.customStatement(
      'UPDATE video_segments SET embedding = \'${_vectorToSql(vec)}\'::vector WHERE id = $segmentId',
    );
    return 1;
  }

  Future<Map<String, int>> embedAllMissing() async {
    var coursesEmbedded = 0;
    var lessonsEmbedded = 0;
    var segmentsEmbedded = 0;

    final coursesNoEmbed = await db.customSelect(
      'SELECT id FROM courses WHERE embedding IS NULL AND is_published = true',
    ).get();
    for (final row in coursesNoEmbed) {
      try {
        coursesEmbedded += await embedCourse(row.read<int>('id'));
      } catch (e) {
        Log.error('EmbeddingService', 'embedCourse ${row.read<int>('id')}: $e');
      }
    }

    final lessonsNoEmbed = await db.customSelect(
      'SELECT id FROM lessons WHERE embedding IS NULL',
    ).get();
    for (final row in lessonsNoEmbed) {
      try {
        lessonsEmbedded += await embedLesson(row.read<int>('id'));
      } catch (e) {
        Log.error('EmbeddingService', 'embedLesson ${row.read<int>('id')}: $e');
      }
    }

    final segmentsNoEmbed = await db.customSelect(
      'SELECT id FROM video_segments WHERE embedding IS NULL',
    ).get();
    for (final row in segmentsNoEmbed) {
      try {
        segmentsEmbedded += await embedVideoSegment(row.read<int>('id'));
      } catch (e) {
        Log.error('EmbeddingService', 'embedSegment ${row.read<int>('id')}: $e');
      }
    }

    Log.info('EmbeddingService',
        'Embedded: $coursesEmbedded courses, $lessonsEmbedded lessons, $segmentsEmbedded segments');

    return {
      'courses': coursesEmbedded,
      'lessons': lessonsEmbedded,
      'segments': segmentsEmbedded,
    };
  }

  Future<List<Map<String, dynamic>>> searchSimilar({
    required String table,
    required List<double> queryVec,
    int limit = 10,
    String? whereClause,
  }) async {
    final vecSql = _vectorToSql(queryVec);
    final where = whereClause != null ? 'AND $whereClause' : '';

    final results = await db.customSelect(
      'SELECT *, 1 - (embedding <=> \'$vecSql\'::vector) AS similarity_score '
      'FROM $table '
      'WHERE embedding IS NOT NULL $where '
      'ORDER BY embedding <=> \'$vecSql\'::vector '
      'LIMIT $limit',
    ).get();

    return results.map((r) => r.data).toList();
  }
}
