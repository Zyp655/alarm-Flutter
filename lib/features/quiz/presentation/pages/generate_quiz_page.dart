import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../bloc/quiz_bloc.dart';
import '../bloc/quiz_event.dart';
import '../bloc/quiz_state.dart';
import 'take_quiz_page.dart';
import '../../../../core/theme/app_colors.dart';

class GenerateQuizPage extends StatefulWidget {
  final bool isForMultiplayer;
  final String? videoUrl;
  final String? lessonTitle;

  const GenerateQuizPage({
    super.key,
    this.isForMultiplayer = false,
    this.videoUrl,
    this.lessonTitle,
  });

  @override
  State<GenerateQuizPage> createState() => _GenerateQuizPageState();
}

class _GenerateQuizPageState extends State<GenerateQuizPage> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  int _numQuestions = 5;
  String _difficulty = 'medium';

  @override
  void initState() {
    super.initState();
    if (widget.lessonTitle != null) {
      _topicController.text = widget.lessonTitle!;
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final cardColor = isDarkMode ? AppColors.darkSurface : Colors.white;

    return BlocProvider(
      create: (context) => di.sl<QuizBloc>(),
      child: Scaffold(
        backgroundColor: isDarkMode
            ? AppColors.darkBackground
            : Colors.grey[100],
        appBar: AppBar(
          title: Text(
            widget.isForMultiplayer ? 'Tạo Quiz cho Phòng' : 'Tạo Quiz AI',
          ),
          centerTitle: true,
          backgroundColor: isDarkMode
              ? AppColors.darkSurface
              : Colors.blueAccent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: BlocConsumer<QuizBloc, QuizState>(
          listener: (context, state) {
            if (state is QuizGenerated) {
              if (widget.isForMultiplayer) {
                context.read<QuizBloc>().add(
                  SaveQuizEvent(
                    userId: 1,
                    isPublic: true,
                  ),
                );
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<QuizBloc>(),
                      child: TakeQuizPage(quiz: state.quiz),
                    ),
                  ),
                );
              }
            } else if (state is QuizSaved) {
              if (widget.isForMultiplayer) {
                Navigator.of(context).pop(state.quizId);
              }
            } else if (state is QuizError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.withAlpha(26),
                            Colors.purple.withAlpha(26),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.info.withAlpha(76)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.info.withAlpha(51),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.auto_awesome,
                              color: AppColors.info,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.videoUrl != null
                                      ? 'Quiz từ Video Bài học'
                                      : 'Tạo Quiz với AI',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.videoUrl != null
                                      ? 'AI sẽ tạo câu hỏi dựa trên nội dung bài học video'
                                      : 'Gemini AI sẽ tạo câu hỏi trắc nghiệm thông minh dựa trên chủ đề bạn chọn',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: textColor.withAlpha(178),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Chủ đề Quiz',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _topicController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText:
                            'VD: Lập trình Flutter, Toán cao cấp, Lịch sử Việt Nam...',
                        prefixIcon: Icon(
                          Icons.topic,
                          color: AppColors.info,
                        ),
                        filled: true,
                        fillColor: cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDarkMode
                                ? Colors.grey[700]!
                                : Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.info,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập chủ đề';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Số câu hỏi: $_numQuestions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.quiz, color: AppColors.info),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Slider(
                              value: _numQuestions.toDouble(),
                              min: 3,
                              max: 15,
                              divisions: 12,
                              activeColor: Colors.blueAccent,
                              label: '$_numQuestions câu',
                              onChanged: (value) {
                                setState(() {
                                  _numQuestions = value.round();
                                });
                              },
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.info,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$_numQuestions',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Độ khó',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildDifficultyChip(
                          'easy',
                          'Dễ',
                          Colors.green,
                          isDarkMode,
                        ),
                        const SizedBox(width: 12),
                        _buildDifficultyChip(
                          'medium',
                          'Trung bình',
                          Colors.orange,
                          isDarkMode,
                        ),
                        const SizedBox(width: 12),
                        _buildDifficultyChip(
                          'hard',
                          'Khó',
                          Colors.red,
                          isDarkMode,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: state is QuizLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<QuizBloc>().add(
                                    GenerateQuizEvent(
                                      topic: _topicController.text,
                                      numQuestions: _numQuestions,
                                      difficulty: _difficulty,
                                      videoUrl: widget.videoUrl,
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.info,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: state is QuizLoading
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Đang tạo Quiz...',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.auto_awesome, size: 24),
                                  SizedBox(width: 12),
                                  Text(
                                    'Tạo Quiz với AI',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(
    String value,
    String label,
    Color color,
    bool isDarkMode,
  ) {
    final isSelected = _difficulty == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _difficulty = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? color
                : (isDarkMode ? Colors.grey[800] : Colors.grey[200]),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDarkMode ? Colors.white70 : Colors.black87),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
