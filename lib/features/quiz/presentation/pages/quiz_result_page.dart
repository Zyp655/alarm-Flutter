import 'package:flutter/material.dart';
import '../../domain/entities/quiz_entity.dart';
import '../../../../core/theme/app_colors.dart';

class QuizResultPage extends StatelessWidget {
  final QuizResultEntity result;

  const QuizResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final cardColor = isDarkMode ? AppColors.darkSurface : Colors.white;

    final scoreColor = result.score >= 8
        ? Colors.green
        : result.score >= 5
        ? Colors.orange
        : Colors.red;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : Colors.grey[100],
      appBar: AppBar(
        title: const Text('Kết quả Quiz'),
        centerTitle: true,
        backgroundColor: isDarkMode
            ? AppColors.darkSurface
            : Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scoreColor.withAlpha(26),
                    scoreColor.withAlpha(13),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: scoreColor.withAlpha(76)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: scoreColor.withAlpha(26),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      result.score >= 8
                          ? Icons.emoji_events
                          : result.score >= 5
                          ? Icons.thumb_up
                          : Icons.sentiment_dissatisfied,
                      color: scoreColor,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    result.score >= 8
                        ? 'Xuất sắc!'
                        : result.score >= 5
                        ? 'Tốt lắm!'
                        : 'Cần cố gắng thêm!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        'Điểm',
                        result.score.toStringAsFixed(1),
                        scoreColor,
                        textColor,
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: textColor.withAlpha(51),
                      ),
                      _buildStatItem(
                        'Đúng',
                        '${result.correctCount}/${result.quiz.totalQuestions}',
                        Colors.green,
                        textColor,
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: textColor.withAlpha(51),
                      ),
                      _buildStatItem(
                        'Tỉ lệ',
                        '${result.scorePercentage.toStringAsFixed(0)}%',
                        Colors.blue,
                        textColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chi tiết câu hỏi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.info.withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    result.quiz.topic,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.info,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ...List.generate(
              result.quiz.questions.length,
              (index) => _buildQuestionReview(
                index: index,
                question: result.quiz.questions[index],
                userAnswer: result.userAnswers[index],
                isDarkMode: isDarkMode,
                cardColor: cardColor,
                textColor: textColor,
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    icon: Icon(Icons.home),
                    label: const Text('Trang chủ'),
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
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    icon: Icon(Icons.refresh),
                    label: const Text('Quiz mới'),
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
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    Color textColor,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: textColor.withAlpha(178)),
        ),
      ],
    );
  }

  Widget _buildQuestionReview({
    required int index,
    required QuestionEntity question,
    required dynamic userAnswer,
    required bool isDarkMode,
    required Color cardColor,
    required Color textColor,
  }) {
    final isCorrect = userAnswer == question.correctIndex;
    final labels = ['A', 'B', 'C', 'D'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect
              ? Colors.green.withAlpha(76)
              : Colors.red.withAlpha(76),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Câu ${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question.question,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),

          ...List.generate(question.options.length, (optionIndex) {
            final isUserAnswer = userAnswer == optionIndex;
            final isCorrectAnswer = question.correctIndex == optionIndex;

            Color? bgColor;
            Color? borderColor;
            if (isCorrectAnswer) {
              bgColor = AppColors.success.withAlpha(26);
              borderColor = AppColors.success;
            } else if (isUserAnswer && !isCorrect) {
              bgColor = AppColors.error.withAlpha(26);
              borderColor = AppColors.error;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      borderColor ??
                      (isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '${labels[optionIndex]}. ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCorrectAnswer ? Colors.green : textColor,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      question.options[optionIndex],
                      style: TextStyle(
                        color: isCorrectAnswer ? Colors.green : textColor,
                      ),
                    ),
                  ),
                  if (isCorrectAnswer)
                    Icon(Icons.check, color: AppColors.success, size: 18),
                  if (isUserAnswer && !isCorrect)
                    Icon(Icons.close, color: AppColors.error, size: 18),
                ],
              ),
            );
          }),

          if (question.explanation != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb, color: AppColors.info, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question.explanation!,
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor.withAlpha(204),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
