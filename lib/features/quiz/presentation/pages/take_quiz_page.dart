import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/quiz_entity.dart';
import '../bloc/quiz_bloc.dart';
import '../bloc/quiz_event.dart';
import '../bloc/quiz_state.dart';
import 'quiz_result_page.dart';
import '../../../../core/theme/app_colors.dart';

class TakeQuizPage extends StatefulWidget {
  final QuizEntity quiz;

  const TakeQuizPage({super.key, required this.quiz});

  @override
  State<TakeQuizPage> createState() => _TakeQuizPageState();
}

class _TakeQuizPageState extends State<TakeQuizPage> {
  int _currentIndex = 0;
  late List<int?> _answers;
  final PageController _pageController = PageController();
  final Stopwatch _questionStopwatch = Stopwatch();
  late List<int> _perQuestionTimeMs;

  @override
  void initState() {
    super.initState();
    _answers = List.filled(widget.quiz.questions.length, null);
    _perQuestionTimeMs = List.filled(widget.quiz.questions.length, 0);
    _questionStopwatch.start();
  }

  @override
  void dispose() {
    _questionStopwatch.stop();
    _pageController.dispose();
    super.dispose();
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      _answers[_currentIndex] = answerIndex;
    });
    context.read<QuizBloc>().add(
      AnswerQuestionEvent(questionIndex: _currentIndex, answer: answerIndex),
    );
  }

  void _nextQuestion() {
    if (_currentIndex < widget.quiz.questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitQuiz() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nộp bài'),
        content: Text(
          'Bạn đã trả lời ${_answers.where((a) => a != null).length}/${widget.quiz.questions.length} câu hỏi. Bạn có chắc muốn nộp bài?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _perQuestionTimeMs[_currentIndex] += _questionStopwatch.elapsedMilliseconds;
              _questionStopwatch.stop();
              context.read<QuizBloc>().add(const SubmitQuizEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.info,
              foregroundColor: Colors.white,
            ),
            child: const Text('Nộp bài'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final cardColor = isDarkMode ? AppColors.darkSurface : Colors.white;

    return BlocListener<QuizBloc, QuizState>(
      listener: (context, state) {
        if (state is QuizCompleted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => QuizResultPage(result: state.result),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: isDarkMode
            ? AppColors.darkBackground
            : Colors.grey[100],
        appBar: AppBar(
          title: Text(widget.quiz.topic),
          centerTitle: true,
          backgroundColor: isDarkMode
              ? AppColors.darkSurface
              : Colors.blueAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            TextButton(
              onPressed: _submitQuiz,
              child: const Text(
                'Nộp bài',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: cardColor,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Câu ${_currentIndex + 1}/${widget.quiz.questions.length}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      Text(
                        '${_answers.where((a) => a != null).length} đã trả lời',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_currentIndex + 1) / widget.quiz.questions.length,
                    backgroundColor: isDarkMode
                        ? Colors.grey[800]
                        : Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation(Colors.blueAccent),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  _perQuestionTimeMs[_currentIndex] += _questionStopwatch.elapsedMilliseconds;
                  _questionStopwatch.reset();
                  _questionStopwatch.start();
                  setState(() => _currentIndex = index);
                },
                itemCount: widget.quiz.questions.length,
                itemBuilder: (context, index) {
                  final question = widget.quiz.questions[index];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(13),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            question.question,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        ...List.generate(
                          question.options.length,
                          (optionIndex) => _buildOptionCard(
                            index: optionIndex,
                            text: question.options[optionIndex],
                            isSelected: _answers[index] == optionIndex,
                            isDarkMode: isDarkMode,
                            cardColor: cardColor,
                            textColor: textColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              color: cardColor,
              child: Row(
                children: [
                  if (_currentIndex > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _previousQuestion,
                        icon: Icon(Icons.arrow_back),
                        label: const Text('Trước'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: AppColors.info),
                          foregroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  if (_currentIndex > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          _currentIndex < widget.quiz.questions.length - 1
                          ? _nextQuestion
                          : _submitQuiz,
                      icon: Icon(
                        _currentIndex < widget.quiz.questions.length - 1
                            ? Icons.arrow_forward
                            : Icons.check,
                      ),
                      label: Text(
                        _currentIndex < widget.quiz.questions.length - 1
                            ? 'Tiếp theo'
                            : 'Nộp bài',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.info,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required int index,
    required String text,
    required bool isSelected,
    required bool isDarkMode,
    required Color cardColor,
    required Color textColor,
  }) {
    final labels = ['A', 'B', 'C', 'D'];

    return GestureDetector(
      onTap: () => _selectAnswer(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent.withAlpha(26) : cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.blueAccent
                : (isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blueAccent
                    : (isDarkMode ? Colors.grey[800] : Colors.grey[200]),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  labels[index],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : textColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 16, color: textColor),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.info),
          ],
        ),
      ),
    );
  }
}
