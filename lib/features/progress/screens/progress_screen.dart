import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import 'package:pathly/core/services/supabase_service.dart';

final progressDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final streak = await SupabaseService.getStreak();
  final completed = await SupabaseService.getCompletedLessonsCount();
  final diagnostic = await SupabaseService.getLatestDiagnosticResult();
  return {
    'streak': streak,
    'completed': completed,
    'diagnostic': diagnostic,
  };
});

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(progressDataProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: data.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error loading progress')),
          data: (d) {
            final streak = d['streak'] as Map<String, dynamic>;
            final completed = d['completed'] as int;
            final diagnostic = d['diagnostic'] as Map<String, dynamic>?;
            final percentage = diagnostic?['percentage'] as int? ?? 0;
            final topicScores =
                diagnostic?['topic_scores'] as Map<String, dynamic>? ?? {};

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Progress', style: AppTextStyles.displayMedium)
                      .animate()
                      .fadeIn(),

                  const SizedBox(height: 8),
                  Text('Track your learning journey',
                          style: AppTextStyles.bodyMedium)
                      .animate()
                      .fadeIn(delay: 100.ms),

                  const SizedBox(height: 28),

                  // Streak cards row
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.local_fire_department_rounded,
                          iconColor: const Color(0xFFFF6B35),
                          label: 'Current Streak',
                          value: '${streak['current_streak']} days',
                        )
                            .animate()
                            .fadeIn(delay: 150.ms)
                            .slideY(begin: 0.2, end: 0),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.emoji_events_rounded,
                          iconColor: const Color(0xFFFFB830),
                          label: 'Best Streak',
                          value: '${streak['longest_streak']} days',
                        )
                            .animate()
                            .fadeIn(delay: 200.ms)
                            .slideY(begin: 0.2, end: 0),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.check_circle_rounded,
                          iconColor: AppColors.primary,
                          label: 'Lessons Done',
                          value: '$completed',
                        )
                            .animate()
                            .fadeIn(delay: 250.ms)
                            .slideY(begin: 0.2, end: 0),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.psychology_rounded,
                          iconColor: const Color(0xFF7C5CBF),
                          label: 'Diagnostic Score',
                          value: '$percentage%',
                        )
                            .animate()
                            .fadeIn(delay: 300.ms)
                            .slideY(begin: 0.2, end: 0),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Overall mastery ring
                  if (diagnostic != null) ...[
                    Text('Diagnostic Breakdown', style: AppTextStyles.h2)
                        .animate()
                        .fadeIn(delay: 350.ms),
                    const SizedBox(height: 16),

                    Center(
                      child: CircularPercentIndicator(
                        radius: 90,
                        lineWidth: 12,
                        percent: percentage / 100,
                        center: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$percentage%',
                              style: AppTextStyles.displayMedium.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            Text('Mastery', style: AppTextStyles.bodySmall),
                          ],
                        ),
                        progressColor: AppColors.primary,
                        backgroundColor: AppColors.primarySurface,
                        circularStrokeCap: CircularStrokeCap.round,
                        animation: true,
                        animationDuration: 800,
                      ).animate().fadeIn(delay: 400.ms).scale(
                            begin: const Offset(0.8, 0.8),
                            curve: Curves.easeOutBack,
                          ),
                    ),

                    const SizedBox(height: 28),

                    // Topic breakdown
                    if (topicScores.isNotEmpty) ...[
                      Text('Topic Breakdown', style: AppTextStyles.h2)
                          .animate()
                          .fadeIn(delay: 450.ms),
                      const SizedBox(height: 16),
                      ...topicScores.entries.map((e) {
                        final score = (e.value as num).toDouble();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _TopicBar(
                            topic: _formatTopic(e.key),
                            score: score,
                          )
                              .animate()
                              .fadeIn(delay: 500.ms)
                              .slideX(begin: 0.2, end: 0),
                        );
                      }),
                    ],
                  ] else ...[
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 32),
                          Icon(Icons.bar_chart_rounded,
                              size: 64, color: AppColors.grey900),
                          const SizedBox(height: 16),
                          Text('No diagnostic data yet',
                              style: AppTextStyles.h3
                                  .copyWith(color: AppColors.grey300)),
                          const SizedBox(height: 8),
                          Text('Complete your diagnostic quiz to see progress',
                              style: AppTextStyles.bodySmall,
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatTopic(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.dark.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 12),
          Text(value, style: AppTextStyles.h2.copyWith(color: AppColors.dark)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _TopicBar extends StatelessWidget {
  final String topic;
  final double score;

  const _TopicBar({required this.topic, required this.score});

  @override
  Widget build(BuildContext context) {
    final color = score >= 70
        ? AppColors.primary
        : score >= 40
            ? const Color(0xFFFFB830)
            : AppColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(topic, style: AppTextStyles.labelMedium),
            Text('${score.toInt()}%',
                style: AppTextStyles.labelMedium.copyWith(color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: score / 100,
            minHeight: 8,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
