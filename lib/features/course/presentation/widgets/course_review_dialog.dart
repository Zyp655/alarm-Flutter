import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CourseReviewDialog extends StatefulWidget {
  final int courseId;
  final String courseTitle;
  final Function(int rating, String comment) onSubmit;
  final double? existingRating;
  final String? existingComment;

  const CourseReviewDialog({
    super.key,
    required this.courseId,
    required this.courseTitle,
    required this.onSubmit,
    this.existingRating,
    this.existingComment,
  });

  static Future<void> show({
    required BuildContext context,
    required int courseId,
    required String courseTitle,
    required Function(int rating, String comment) onSubmit,
    double? existingRating,
    String? existingComment,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CourseReviewDialog(
        courseId: courseId,
        courseTitle: courseTitle,
        onSubmit: onSubmit,
        existingRating: existingRating,
        existingComment: existingComment,
      ),
    );
  }

  @override
  State<CourseReviewDialog> createState() => _CourseReviewDialogState();
}

class _CourseReviewDialogState extends State<CourseReviewDialog> {
  late int _selectedRating;
  late TextEditingController _commentController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedRating = widget.existingRating?.round() ?? 0;
    _commentController = TextEditingController(text: widget.existingComment);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn số sao đánh giá'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await widget.onSubmit(_selectedRating, _commentController.text.trim());
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đánh giá của bạn đã được gửi! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể gửi đánh giá: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top + 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.rate_review_outlined,
                    size: 48,
                    color: Color(0xFF6C63FF),
                  ).animate().scale(delay: 100.ms),
                  const SizedBox(height: 12),
                  Text(
                    'Đánh giá khóa học',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(delay: 150.ms),
                  const SizedBox(height: 4),
                  Text(
                    widget.courseTitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 200.ms),
                ],
              ),
            ),
            _buildStarRating().animate().fadeIn(delay: 250.ms),
            const SizedBox(height: 20),
            Text(
              _getRatingLabel(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _selectedRating > 0
                    ? Colors.amber[700]
                    : Colors.grey[400],
              ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _commentController,
                maxLines: 4,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Chia sẻ trải nghiệm của bạn về khóa học này...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF6C63FF)),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 350.ms),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.send, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Gửi đánh giá',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Đánh giá của bạn giúp cải thiện trải nghiệm cho các học viên khác',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isSelected = starIndex <= _selectedRating;

        return GestureDetector(
          onTap: () => setState(() => _selectedRating = starIndex),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: isSelected ? 1.2 : 1.0),
              duration: const Duration(milliseconds: 200),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Icon(
                    isSelected ? Icons.star : Icons.star_border,
                    size: 44,
                    color: isSelected ? Colors.amber : Colors.grey[300],
                  ),
                );
              },
            ),
          ),
        ).animate(delay: Duration(milliseconds: 50 * index)).scale();
      }),
    );
  }

  String _getRatingLabel() {
    switch (_selectedRating) {
      case 1:
        return 'Rất tệ 😞';
      case 2:
        return 'Tệ 😐';
      case 3:
        return 'Bình thường 🙂';
      case 4:
        return 'Tốt 😊';
      case 5:
        return 'Tuyệt vời 🤩';
      default:
        return 'Chọn số sao';
    }
  }
}
