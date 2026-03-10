import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class StreakCard extends StatelessWidget {
  final int streak;
  final int lessonsCompleted;

  const StreakCard({
    super.key,
    required this.streak,
    required this.lessonsCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Flame icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('🔥', style: TextStyle(fontSize: 28)),
            ),
          ).animate().scale(
                begin: const Offset(0.8, 0.8),
                curve: Curves.easeOutBack,
                delay: 200.ms,
              ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streak Day Streak',
                  style: AppTextStyles.h2.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keep it up! Come back tomorrow.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // Lessons badge
          Column(
            children: [
              Text(
                '$lessonsCompleted',
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.white,
                  fontSize: 28,
                ),
              ),
              Text(
                'lessons',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.white.withOpacity(0.65),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }
}
