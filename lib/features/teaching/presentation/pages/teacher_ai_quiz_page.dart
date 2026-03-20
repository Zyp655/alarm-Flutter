import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart' as archive;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import '../../../../core/api/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/quiz_question_card.dart';

class TeacherAiQuizPage extends StatefulWidget {
  final int courseId;
  final int? moduleId;
  final String? initialContent;

  const TeacherAiQuizPage({
    super.key,
    required this.courseId,
    this.moduleId,
    this.initialContent,
  });

  @override
  State<TeacherAiQuizPage> createState() => _TeacherAiQuizPageState();
}

class _TeacherAiQuizPageState extends State<TeacherAiQuizPage> {
  int _step = 0;
  final _contentController = TextEditingController();
  int _numQuestions = 10;
  String _difficulty = 'medium';
  String _quizTitle = '';
  bool _isGenerating = false;
  List<Map<String, dynamic>> _draftQuestions = [];
  String? _importedFileName;
  bool _isImporting = false;
  List<String> _extractedImages = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialContent != null && widget.initialContent!.isNotEmpty) {
      _contentController.text = widget.initialContent!;
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _importFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'md', 'csv', 'json', 'pdf', 'docx'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      setState(() => _isImporting = true);

      String text = '';
      List<String> images = [];
      final ext = file.extension?.toLowerCase() ?? '';

      if (ext == 'pdf') {
        Uint8List? bytes = file.bytes;
        bytes ??= await File(file.path!).readAsBytes();
        final pdfDoc = PdfDocument(inputBytes: bytes);
        final extractor = PdfTextExtractor(pdfDoc);
        text = extractor.extractText();
        pdfDoc.dispose();
        try {
          final renderDoc = await pdfx.PdfDocument.openData(bytes);
          final pageCount = renderDoc.pagesCount.clamp(0, 5);
          for (int i = 1; i <= pageCount && images.length < 5; i++) {
            final page = await renderDoc.getPage(i);
            final pageImage = await page.render(
              width: page.width * 1.5,
              height: page.height * 1.5,
              format: pdfx.PdfPageImageFormat.png,
            );
            await page.close();
            if (pageImage != null && pageImage.bytes.isNotEmpty) {
              images.add(base64Encode(pageImage.bytes));
            }
          }
          await renderDoc.close();
        } catch (_) {}
      } else if (ext == 'docx') {
        Uint8List? bytes = file.bytes;
        bytes ??= await File(file.path!).readAsBytes();
        text = _extractDocxText(bytes);
        images = _extractDocxImages(bytes);
      } else {
        if (file.bytes != null) {
          text = utf8.decode(file.bytes!, allowMalformed: true);
        } else if (file.path != null) {
          text = await File(file.path!).readAsString();
        }
      }

      if (text.trim().isEmpty && images.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File rỗng hoặc không trích xuất được nội dung'),
            ),
          );
        }
        setState(() => _isImporting = false);
        return;
      }

      setState(() {
        _contentController.text = text;
        _importedFileName = file.name;
        _extractedImages = images;
        _isImporting = false;
      });

      if (images.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã trích xuất ${images.length} ảnh từ file')),
        );
      }
    } catch (e) {
      setState(() => _isImporting = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi import: $e')));
      }
    }
  }

  Future<void> _generateQuiz() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung tài liệu')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/teacher/generate-quiz-from-file'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'fileContent': _contentController.text,
          'numQuestions': _numQuestions,
          'difficulty': _difficulty,
          if (_extractedImages.isNotEmpty) ...{
            'imageBase64List': _extractedImages,
            'imageSource':
                _importedFileName?.toLowerCase().endsWith('.pdf') == true
                ? 'pdf'
                : 'docx',
            'imageDetail': 'high',
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final questions = (data['questions'] as List).map((q) {
          final m = Map<String, dynamic>.from(q as Map);
          m['_editing'] = false;
          return m;
        }).toList();

        setState(() {
          _draftQuestions = questions;
          _step = 1;
          _isGenerating = false;
        });
      } else {
        final err = jsonDecode(response.body);
        setState(() => _isGenerating = false);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(err['error'] ?? 'Lỗi')));
        }
      }
    } catch (e) {
      setState(() => _isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Lỗi kết nối')));
      }
    }
  }

  Future<void> _publishQuiz() async {
    if (_quizTitle.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên quiz')));
      return;
    }

    if (_draftQuestions.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cần ít nhất 1 câu hỏi')));
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId') ?? 0;

      final quizQuestions = _draftQuestions.map((q) {
        final options = (q['options'] as List).cast<String>();
        final correctIdx = q['correctIndex'] as int? ?? 0;
        return {
          'question': q['question'],
          'options': options,
          'correctAnswer': options[correctIdx],
          'correctIndex': correctIdx,
          'explanation': q['explanation'] ?? '',
        };
      }).toList();

      final token = prefs.getString('token');
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/quiz/save'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': userId,
          'isPublic': true,
          if (widget.moduleId != null) 'moduleId': widget.moduleId,
          'quiz': {
            'topic': _quizTitle,
            'difficulty': _difficulty,
            'subjectContext': 'courseId:${widget.courseId}',
            if (widget.moduleId != null) 'moduleId': widget.moduleId,
            'questions': quizQuestions,
          },
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Quiz đã được lưu thành công!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Lỗi khi lưu quiz')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Lỗi kết nối')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(_step == 0 ? '📄 Import Nội dung' : '📝 Duyệt Quiz'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _step == 0
          ? _buildImportStep(cs, isDark)
          : _buildDraftReviewStep(cs, isDark),
    );
  }

  Widget _buildImportStep(ColorScheme cs, bool isDark) {
    final hasContent = _contentController.text.trim().isNotEmpty;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          if (!hasContent)
            GestureDetector(
              onTap: _isImporting ? null : _importFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 48),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: _isImporting
                          ? const SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            )
                          : const Icon(
                              Icons.upload_file_rounded,
                              size: 32,
                              color: AppColors.primary,
                            ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isImporting
                          ? '\u0110ang \u0111\u1ecdc t\u00e0i li\u1ec7u...'
                          : 'Ch\u1ecdn t\u00e0i li\u1ec7u',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'H\u1ed7 tr\u1ee3: PDF, DOCX, TXT, MD, CSV, JSON',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _importedFileName?.endsWith('.pdf') == true
                          ? Icons.picture_as_pdf_rounded
                          : Icons.description_rounded,
                      color: AppColors.success,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _importedFileName ?? 'T\u00e0i li\u1ec7u',
                          style: TextStyle(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_contentController.text.split(' ').length} t\u1eeb \u2022 S\u1eb5n s\u00e0ng t\u1ea1o quiz',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: _importFile,
                        icon: const Icon(Icons.swap_horiz_rounded, size: 20),
                        tooltip: '\u0110\u1ed5i file',
                        color: cs.onSurfaceVariant,
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _contentController.clear();
                            _importedFileName = null;
                          });
                        },
                        icon: const Icon(Icons.close_rounded, size: 20),
                        tooltip: 'X\u00f3a',
                        color: AppColors.error,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 120,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _contentController.text,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.5,
                  ),
                  maxLines: 8,
                  overflow: TextOverflow.fade,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'S\u1ed1 c\u00e2u: $_numQuestions',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Slider(
                      value: _numQuestions.toDouble(),
                      min: 3,
                      max: 20,
                      divisions: 17,
                      activeColor: AppColors.primary,
                      label: '$_numQuestions',
                      onChanged: (v) =>
                          setState(() => _numQuestions = v.round()),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '\u0110\u1ed9 kh\u00f3',
            style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildDiffChip('easy', 'D\u1ec5', AppColors.success, isDark),
              const SizedBox(width: 8),
              _buildDiffChip('medium', 'TB', AppColors.warning, isDark),
              const SizedBox(width: 8),
              _buildDiffChip('hard', 'Kh\u00f3', AppColors.error, isDark),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: (!hasContent || _isGenerating) ? null : _generateQuiz,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                _isGenerating
                    ? '\u0110ang t\u1ea1o quiz...'
                    : 'T\u1ea1o Quiz AI',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiffChip(String value, String label, Color color, bool isDark) {
    final selected = _difficulty == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _difficulty = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? color
                : (isDark ? Colors.grey[800] : Colors.grey[200]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black87),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDraftReviewStep(ColorScheme cs, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          color: isDark ? AppColors.darkSurface : Colors.white,
          child: Column(
            children: [
              TextField(
                onChanged: (v) => _quizTitle = v,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Nhập tên Quiz...',
                  hintStyle: TextStyle(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  prefixIcon: const Icon(Icons.quiz),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${_draftQuestions.length} câu hỏi',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _addManualQuestion,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Thêm câu'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _publishQuiz,
                    icon: const Icon(Icons.publish, size: 18),
                    label: const Text('Lưu Quiz'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _draftQuestions.length,
            itemBuilder: (_, i) => QuizQuestionCard(
              question: _draftQuestions[i],
              index: i,
              onToggleEdit: () {
                setState(() => _draftQuestions[i]['_editing'] = !(_draftQuestions[i]['_editing'] == true));
              },
              onDelete: () {
                setState(() => _draftQuestions.removeAt(i));
              },
              onChanged: (q) => setState(() {}),
            ),
          ),
        ),
      ],
    );
  }

  void _addManualQuestion() {
    setState(() {
      _draftQuestions.add({
        'question': '',
        'options': ['A. ', 'B. ', 'C. ', 'D. '],
        'correctIndex': 0,
        'explanation': '',
        'difficulty': _difficulty,
        '_editing': true,
      });
    });
  }




  String _extractDocxText(Uint8List bytes) {
    final decoded = archive.ZipDecoder().decodeBytes(bytes);
    final docFile = decoded.files.firstWhere(
      (f) => f.name == 'word/document.xml',
      orElse: () => throw Exception('Invalid DOCX'),
    );
    final xml = utf8.decode(docFile.content as List<int>);
    final buffer = StringBuffer();
    final textRegex = RegExp(r'<w:t[^>]*>(.*?)</w:t>', dotAll: true);
    final paragraphs = xml.split('</w:p>');
    for (final para in paragraphs) {
      final line = StringBuffer();
      for (final match in textRegex.allMatches(para)) {
        line.write(match.group(1) ?? '');
      }
      if (line.isNotEmpty) {
        buffer.writeln(line);
      }
    }
    var result = buffer.toString();
    result = result.replaceAll(RegExp(r'<[^>]+>'), '');
    return result.trim();
  }

  List<String> _extractDocxImages(Uint8List bytes) {
    final decoded = archive.ZipDecoder().decodeBytes(bytes);
    final images = <String>[];
    final imageExtensions = ['.png', '.jpg', '.jpeg', '.gif', '.bmp'];
    for (final file in decoded.files) {
      if (!file.isFile) continue;
      if (!file.name.startsWith('word/media/')) continue;
      final ext = file.name.toLowerCase();
      if (!imageExtensions.any((e) => ext.endsWith(e))) continue;
      if (file.content == null) continue;
      final contentBytes = file.content as List<int>;
      if (contentBytes.length > 500 * 1024) continue;
      images.add(base64Encode(Uint8List.fromList(contentBytes)));
      if (images.length >= 5) break;
    }
    return images;
  }
}
