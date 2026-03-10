import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';

class DiagnosticResultScreen extends StatelessWidget {
  final Map<String, dynamic> results;

  const DiagnosticResultScreen({super.key, required this.results});

  String get _headline {
    final pct = results['percentage'] as int;
    if (pct >= 80) return 'Outstanding! 🎉';
    if (pct >= 60) return 'Great effort! 💪';
    if (pct >= 40) return 'Good start! 🌱';
    return "Let's build it up! 🚀";
  }

  String get _message {
    final pct = results['percentage'] as int;
    if (pct >= 80)
      return "You've got a strong foundation. Your path will focus on mastery and advanced topics.";
    if (pct >= 60)
      return "You're doing well! We'll strengthen your weak spots and push you further.";
    if (pct >= 40)
      return "You have a decent base. Your path will fill in the gaps and build momentum.";
    return "No worries — everyone starts somewhere. Your path is built to take you from zero to confident.";
  }

  Color get _scoreColor {
    final pct = results['percentage'] as int;
    if (pct >= 80) return AppColors.success;
    if (pct >= 60) return AppColors.primary;
    if (pct >= 40) return AppColors.warning;
    return AppColors.info;
  }

  @override
  Widget build(BuildContext context) {
    final pct = results['percentage'] as int;
    final score = results['score'] as int;
    final total = results['total'] as int;
    final topicScores = results['topic_scores'] as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),

              // Score ring
              Center(
                child: CircularPercentIndicator(
                  radius: 90,
                  lineWidth: 12,
                  percent: pct / 100,
                  animation: true,
                  animationDuration: 1200,
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: _scoreColor,
                  backgroundColor: AppColors.grey100,
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$pct%',
                        style: AppTextStyles.displayLarge
                            .copyWith(color: _scoreColor),
                      ),
                      Text(
                        '$score/$total correct',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(begin: const Offset(0.8, 0.8)),

              const SizedBox(height: 40),

              Text(_headline, style: AppTextStyles.displayMedium)
                  .animate()
                  .fadeIn(delay: 400.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: 12),

              Text(_message, style: AppTextStyles.bodyLarge)
                  .animate()
                  .fadeIn(delay: 500.ms),

              const SizedBox(height: 36),

              // Topic breakdown
              Text('Topic Breakdown', style: AppTextStyles.h3)
                  .animate()
                  .fadeIn(delay: 600.ms),

              const SizedBox(height: 16),

              ...topicScores.entries.toList().asMap().entries.map((entry) {
                final index = entry.key;
                final topic = entry.value.key;
                final data = entry.value.value as Map<String, dynamic>;
                final topicPct =
                    ((data['correct'] as int) / (data['total'] as int) * 100)
                        .round();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TopicRow(
                    topic: _formatTopic(topic),
                    percentage: topicPct,
                    delay: 700 + (index * 80),
                  ),
                );
              }),

              const SizedBox(height: 40),

              // CTA
              ElevatedButton(
                onPressed: () => context.go(
                  AppRoutes.pathGenerating,
                  extra: results,
                ),
                child: const Text('Build My Learning Path'),
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 16),

              OutlinedButton(
                onPressed: () => context.go(AppRoutes.diagnosticQuiz,
                    extra: results['level']),
                child: const Text('Retake Diagnostic'),
              ).animate().fadeIn(delay: 850.ms),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTopic(String topic) {
    return topic
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}

class _TopicRow extends StatelessWidget {
  final String topic;
  final int percentage;
  final int delay;

  const _TopicRow({
    required this.topic,
    required this.percentage,
    required this.delay,
  });

  Color get _color {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 50) return AppColors.primary;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey100),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(topic, style: AppTextStyles.labelLarge),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: percentage / 100),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (_, value, __) => LinearProgressIndicator(
                      value: value,
                      backgroundColor: AppColors.grey100,
                      valueColor: AlwaysStoppedAnimation<Color>(_color),
                      minHeight: 6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '$percentage%',
            style: AppTextStyles.h3.copyWith(color: _color),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay))
        .slideX(begin: 0.2, end: 0);
  }
}
