import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class RatingSectionWidget extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final Map<String, int> distribution;

  const RatingSectionWidget({
    super.key,
    required this.averageRating,
    required this.totalReviews,
    required this.distribution,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingXl,
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: AppSpacing.borderRadiusLg,
      ),
      child: Row(
        children: [
          _AverageRatingDisplay(
            rating: averageRating,
            totalReviews: totalReviews,
          ),
          AppSpacing.gapH16,
          Expanded(
            child: _RatingDistribution(
              distribution: distribution,
              totalReviews: totalReviews,
            ),
          ),
        ],
      ),
    );
  }
}

class _AverageRatingDisplay extends StatelessWidget {
  final double rating;
  final int totalReviews;

  const _AverageRatingDisplay({
    required this.rating,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            color: AppColors.textPrimaryDark,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (i) {
            return Icon(
              i < rating.round() ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 20,
            );
          }),
        ),
        AppSpacing.gapV4,
        Text(
          '$totalReviews đánh giá',
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
      ],
    );
  }
}

class _RatingDistribution extends StatelessWidget {
  final Map<String, int> distribution;
  final int totalReviews;

  const _RatingDistribution({
    required this.distribution,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(5, (i) {
        final star = 5 - i;
        final count = distribution['$star'] ?? 0;
        final percent = totalReviews > 0 ? count / totalReviews : 0.0;

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
                    backgroundColor: AppColors.darkSurfaceVariant,
                    valueColor: const AlwaysStoppedAnimation(Colors.amber),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$count',
                style: TextStyle(color: Colors.grey[400], fontSize: 11),
              ),
            ],
          ),
        );
      }),
    );
  }
}
