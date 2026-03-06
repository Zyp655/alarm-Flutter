import 'dart:io';
import 'dart:math';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final moduleId = int.tryParse(id);
  if (moduleId == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'ID module không hợp lệ'},
    );
  }

  try {
    final db = context.read<AppDatabase>();

    final modules = await (db.select(db.modules)
          ..where((m) => m.id.equals(moduleId)))
        .get();

    if (modules.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Không tìm thấy module'},
      );
    }

    final module = modules.first;

    final lessons = await (db.select(db.lessons)
          ..where((l) => l.moduleId.equals(moduleId))
          ..orderBy([(l) => OrderingTerm.asc(l.orderIndex)]))
        .get();

    if (lessons.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'error':
              'Module chưa có bài học nào. Hãy thêm bài học trước khi tạo quiz.'
        },
      );
    }

    final rng = Random();
    final questions = <Map<String, dynamic>>[];
    final lessonTitles = lessons.map((l) => l.title).toList();

    for (var i = 0; i < lessons.length; i++) {
      final lesson = lessons[i];
      final title = lesson.title;
      final content = lesson.textContent;
      final isVideo = lesson.type == 'video';
      final hasContent = content != null && content.trim().isNotEmpty;

      final contentSnippets =
          hasContent ? _extractKeyPhrases(content) : <String>[];

      if (hasContent && contentSnippets.length >= 2) {
        questions.add({
          'question': 'Bài học "$title" đề cập đến nội dung nào sau đây?',
          'questionType': 'multiple_choice',
          'options': [
            contentSnippets[0],
            'Phương pháp quản lý doanh nghiệp hiện đại',
            'Nguyên lý thiết kế giao diện người dùng',
            'Quy trình phát triển phần mềm Agile',
          ]..shuffle(rng),
          'correctIndex': -1, // Will be set below
          'correctAnswer': contentSnippets[0],
          'explanation':
              'Bài học "$title" trình bày về: ${contentSnippets[0]}.',
        });

        final opts = questions.last['options'] as List;
        questions.last['correctIndex'] = opts.indexOf(contentSnippets[0]);
      } else {
        questions.add({
          'question':
              'Chủ đề chính của bài ${isVideo ? 'video' : 'học'} "$title" trong chương "${module.title}" là gì?',
          'questionType': 'multiple_choice',
          'options': [
            title,
            _generateDistractor(title, 0),
            _generateDistractor(title, 1),
            _generateDistractor(title, 2),
          ]..shuffle(rng),
          'correctIndex': -1,
          'correctAnswer': title,
          'explanation':
              'Bài ${isVideo ? 'video' : 'học'} này có tên "$title", nằm trong chương "${module.title}".',
        });
        final opts = questions.last['options'] as List;
        questions.last['correctIndex'] = opts.indexOf(title);
      }

      if (hasContent && contentSnippets.length >= 3) {
        final correct = contentSnippets[1];
        final wrongOptions = [
          'Tối ưu hóa hiệu suất hệ thống',
          'Bảo trì và nâng cấp phần cứng',
          'Quản lý rủi ro trong dự án',
        ];
        final allOpts = [correct, ...wrongOptions]..shuffle(rng);
        questions.add({
          'question': 'Trong bài "$title", khái niệm nào được đề cập?',
          'questionType': 'multiple_choice',
          'options': allOpts,
          'correctIndex': allOpts.indexOf(correct),
          'correctAnswer': correct,
          'explanation': 'Bài "$title" có đề cập đến: $correct.',
        });
      }

      if (i < lessons.length - 1) {
        final nextLesson = lessons[i + 1];
        final opts = ['Đúng', 'Sai'];
        questions.add({
          'question':
              'Trong chương "${module.title}", bài "$title" được học TRƯỚC bài "${nextLesson.title}".',
          'questionType': 'multiple_choice',
          'options': opts,
          'correctIndex': 0,
          'correctAnswer': 'Đúng',
          'explanation':
              'Thứ tự đúng: "$title" (bài ${i + 1}) → "${nextLesson.title}" (bài ${i + 2}).',
        });
      }

      if (isVideo) {
        final opts = [
          'Xem video bài giảng',
          'Đọc tài liệu PDF',
          'Làm bài tập thực hành',
          'Tham gia thảo luận nhóm',
        ];
        questions.add({
          'question': 'Bài "$title" sử dụng hình thức giảng dạy nào?',
          'questionType': 'multiple_choice',
          'options': opts,
          'correctIndex': 0,
          'correctAnswer': 'Xem video bài giảng',
          'explanation':
              'Bài "$title" là bài học dạng video, sinh viên cần xem video để nắm nội dung.',
        });
      }

      if (hasContent) {
        final summary =
            content.length > 100 ? '${content.substring(0, 100)}...' : content;
        final opts = [
          title,
          ...lessonTitles.where((t) => t != title).take(3),
        ];
        if (opts.length >= 4) {
          opts.shuffle(rng);
          questions.add({
            'question': 'Đoạn nội dung sau thuộc bài học nào?\n"$summary"',
            'questionType': 'multiple_choice',
            'options': opts.take(4).toList(),
            'correctIndex': -1,
            'correctAnswer': title,
            'explanation': 'Đoạn nội dung trên thuộc bài "$title".',
          });
          final finalOpts = questions.last['options'] as List;
          questions.last['correctIndex'] = finalOpts.indexOf(title);
        }
      }
    }

    questions.shuffle(rng);
    final maxQ = questions.length > 10
        ? 10
        : (questions.length < 5 ? questions.length : 7);
    final selectedQuestions = questions.take(maxQ).toList();

    final videoLessons = lessons.where((l) => l.type == 'video').length;
    final textLessons = lessons
        .where((l) => l.textContent != null && l.textContent!.trim().isNotEmpty)
        .length;

    return Response.json(
      body: {
        'quiz': {
          'moduleId': moduleId,
          'topic': 'Quiz: ${module.title}',
          'difficulty': 'medium',
          'questionCount': selectedQuestions.length,
        },
        'questions': selectedQuestions,
        'message':
            'Quiz tạo từ ${lessons.length} bài học ($videoLessons video, $textLessons có nội dung text)',
        'sources': {
          'totalLessons': lessons.length,
          'videoLessons': videoLessons,
          'textLessons': textLessons,
          'moduleName': module.title,
        },
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Lỗi tạo quiz: $e'},
    );
  }
}

List<String> _extractKeyPhrases(String content) {
  final sentences = content
      .replaceAll(RegExp(r'[#*\-_>]'), '')
      .split(RegExp(r'[.!?\n]'))
      .map((s) => s.trim())
      .where((s) => s.length > 10 && s.length < 200)
      .toList();

  if (sentences.isEmpty) return [];

  return sentences.take(5).toList();
}

String _generateDistractor(String correctTitle, int variant) {
  final distractors = [
    [
      'Giới thiệu ngôn ngữ Python',
      'Thiết kế cơ sở dữ liệu',
      'Mạng máy tính cơ bản'
    ],
    ['Lập trình hướng đối tượng', 'An ninh mạng', 'Trí tuệ nhân tạo'],
    ['Phân tích yêu cầu phần mềm', 'Hệ điều hành Linux', 'Điện toán đám mây'],
  ];
  return distractors[variant % 3][variant % 3];
}
