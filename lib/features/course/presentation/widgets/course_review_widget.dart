import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/api/api_constants.dart';

class CourseReviewWidget extends StatefulWidget {
  final int courseId;
  final int userId;
  final bool allowReview;

  const CourseReviewWidget({
    super.key,
    required this.courseId,
    required this.userId,
    this.allowReview = true,
  });

  @override
  State<CourseReviewWidget> createState() => _CourseReviewWidgetState();
}

class _CourseReviewWidgetState extends State<CourseReviewWidget> {
  Map<String, dynamic>? _reviewsData;
  bool _isLoading = true;
  int _myRating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/courses/${widget.courseId}/reviews'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _reviewsData = jsonDecode(response.body);
          _isLoading = false;

          final reviews = _reviewsData!['reviews'] as List;
          final myReview = reviews
              .where((r) => r['userId'] == widget.userId)
              .firstOrNull;
          if (myReview != null) {
            _myRating = myReview['rating'] as int;
            _commentController.text = myReview['comment'] ?? '';
          }
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitReview() async {
    if (_myRating == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn số sao')));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/courses/${widget.courseId}/reviews'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': widget.userId,
          'rating': _myRating,
          'comment': _commentController.text.isNotEmpty
              ? _commentController.text
              : null,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã lưu đánh giá!')));
        _loadReviews();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRatingSummary(),
          if (widget.allowReview) ...[
            const SizedBox(height: 24),
            _buildMyReviewSection(),
          ],
          const SizedBox(height: 24),
          _buildReviewsList(),
        ],
      ),
    );
  }

  Widget _buildRatingSummary() {
    if (_reviewsData == null) return const SizedBox();

    final avgRating = _reviewsData!['averageRating'] as num;
    final totalReviews = _reviewsData!['totalReviews'] as int;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                avgRating.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < avgRating.round() ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 18,
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalReviews đánh giá',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(child: _buildDistribution()),
        ],
      ),
    );
  }

  Widget _buildDistribution() {
    final distribution = _reviewsData!['distribution'] as Map<String, dynamic>;
    final total = _reviewsData!['totalReviews'] as int;

    return Column(
      children: List.generate(5, (i) {
        final star = 5 - i;
        final count = distribution['$star'] as int? ?? 0;
        final percent = total > 0 ? count / total : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Text(
                '$star',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.star, color: Colors.amber, size: 12),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: percent,
                    backgroundColor: const Color(0xFF0F3460),
                    valueColor: const AlwaysStoppedAnimation(Colors.amber),
                    minHeight: 6,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMyReviewSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đánh giá của bạn',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              return GestureDetector(
                onTap: () => setState(() => _myRating = i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    i < _myRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 36,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Nhận xét của bạn về khóa học...',
              hintStyle: TextStyle(color: Colors.grey[600]),
              filled: true,
              fillColor: const Color(0xFF0F3460),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Gửi đánh giá'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    if (_reviewsData == null) return const SizedBox();

    final reviews = _reviewsData!['reviews'] as List;

    if (reviews.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 8),
            Text(
              'Chưa có đánh giá nào',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tất cả đánh giá',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...reviews.map((review) => _buildReviewCard(review)),
      ],
    );
  }

  Widget _buildReviewCard(dynamic review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF6C63FF),
                child: Text(
                  (review['userName'] as String? ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['userName'] ?? 'Anonymous',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (i) {
                          return Icon(
                            i < (review['rating'] as int)
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 14,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(review['createdAt']),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review['comment'] != null &&
              (review['comment'] as String).isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review['comment'],
              style: TextStyle(color: Colors.grey[300], fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return '';
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }
}
