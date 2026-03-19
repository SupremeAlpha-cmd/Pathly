import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/services/supabase_service.dart';
import '../../../features/study_path/screens/study_path_screen.dart';
import '../widgets/streak_card.dart';
import '../widgets/subject_progress_card.dart';
import '../widgets/progress_ring.dart';

// Providers for dashboard data
final streakProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await SupabaseService.getStreak();
});

final savedStudyPathProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  return await SupabaseService.getStudyPath();
});

final lessonsCountProvider = FutureProvider<int>((ref) async {
  return await SupabaseService.getCompletedLessonsCount();
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final firstName = (user?.userMetadata?['full_name'] as String? ?? 'there')
        .split(' ')
        .first;
    // Load from Supabase if not in memory
    final studyPath = ref.watch(studyPathProvider) ?? 
        ref.watch(savedStudyPathProvider).valueOrNull;
    
    // Sync to in-memory provider
    if (studyPath != null && ref.read(studyPathProvider) == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(studyPathProvider.notifier).state = studyPath;
      });
    }

    // Build subject progress from study path if available
    final modules = studyPath != null
        ? List<Map<String, dynamic>>.from(studyPath['modules'] as List? ?? [])
        : <Map<String, dynamic>>[];

    final mastery = (studyPath?['mastery_percentage'] as num?)?.toInt() ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top bar
            SliverAppBar(
              expandedHeight: 140,
              pinned: true,
              backgroundColor: AppColors.background,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: const SizedBox.shrink(),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${_greeting()},',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.dark.withOpacity(0.6),
                            ),
                          ),
                          Text(
                            firstName,
                            style: AppTextStyles.displayMedium,
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

                      // Avatar + settings (pushed to bottom of flexible space)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () => _showSettingsSheet(context, ref),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  firstName[0].toUpperCase(),
                                  style: AppTextStyles.h2.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 100.ms),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Streak card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ref.watch(streakProvider).when(
                  data: (streak) => StreakCard(
                    streak: streak['current_streak'] as int? ?? 0,
                    lessonsCompleted: ref.watch(lessonsCountProvider).valueOrNull ?? 0,
                  ),
                  loading: () => StreakCard(streak: 0, lessonsCompleted: 0),
                  error: (_, __) => StreakCard(streak: 0, lessonsCompleted: 0),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Overall progress
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text('Your Progress', style: AppTextStyles.h3),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Progress rings row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.grey100),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ProgressRing(
                        percentage: mastery,
                        label: 'Mastery',
                        color: AppColors.primary,
                      ),
                      ProgressRing(
                        percentage: modules.isEmpty ? 0 : 5,
                        label: 'Lessons',
                        color: AppColors.info,
                      ),
                      ProgressRing(
                        percentage: modules.isEmpty ? 0 : 20,
                        label: 'Path',
                        color: AppColors.accent,
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1, end: 0),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Continue learning / Start path
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: studyPath == null
                    ? _BuildPathBanner(onTap: () => context.go(AppRoutes.levelSelection))
                    : _ContinueLearningCard(
                        modules: modules,
                        onTap: () => context.go(AppRoutes.studyPath),
                      ),
              ).animate().fadeIn(delay: 400.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Modules progress
            if (modules.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text('Module Progress', style: AppTextStyles.h3),
                ).animate().fadeIn(delay: 450.ms),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= modules.length) return null;
                      final module = modules[index];
                      final colors = [
                        AppColors.primary,
                        AppColors.info,
                        AppColors.accent,
                        AppColors.success,
                        AppColors.warning,
                      ];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SubjectProgressCard(
                          subject: module['title'] as String? ?? 'Module ${index + 1}',
                          percentage: index == 0 ? mastery : 0,
                          lessonsLeft: (module['lessons'] as List?)?.length ?? 0,
                          color: colors[index % colors.length],
                          animationIndex: index + 1,
                          onTap: () => context.go(AppRoutes.studyPath),
                        ),
                      );
                    },
                    childCount: modules.length,
                  ),
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.route_rounded, color: AppColors.primary),
              title: Text('My Learning Path', style: AppTextStyles.labelLarge),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.studyPath);
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh_rounded, color: AppColors.info),
              title: Text('Retake Diagnostic', style: AppTextStyles.labelLarge),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.levelSelection);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: Text('Log Out',
                  style: AppTextStyles.labelLarge.copyWith(color: AppColors.error)),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authNotifierProvider.notifier).signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BuildPathBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _BuildPathBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.accentSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.accent.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Text('🗺️', style: TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("You don't have a path yet", style: AppTextStyles.h3),
                  const SizedBox(height: 4),
                  Text(
                    'Take the diagnostic quiz and let AI build your personalised learning path.',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: AppColors.grey500),
          ],
        ),
      ),
    );
  }
}

class _ContinueLearningCard extends StatelessWidget {
  final List<Map<String, dynamic>> modules;
  final VoidCallback onTap;

  const _ContinueLearningCard({required this.modules, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final nextModule = modules.isNotEmpty ? modules[0] : null;
    final nextLesson = nextModule != null
        ? (nextModule['lessons'] as List?)?.first as Map<String, dynamic>?
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: AppColors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Continue Learning', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 4),
                  Text(
                    nextLesson?['title'] as String? ??
                        nextModule?['title'] as String? ??
                        'Pick up where you left off',
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}


/// Alias used by MainScaffold — same as DashboardScreen body
typedef DashboardContent = DashboardScreen;