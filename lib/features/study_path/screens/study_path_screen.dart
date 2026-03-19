import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import 'package:pathly/features/auth/providers/auth_provider.dart';
import '../widgets/path_module_card.dart';

// Provider to hold the generated study path
final studyPathProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

class StudyPathScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? pathData;
  const StudyPathScreen({super.key, this.pathData});

  @override
  ConsumerState<StudyPathScreen> createState() => _StudyPathScreenState();
}

class _StudyPathScreenState extends ConsumerState<StudyPathScreen> {
  final Set<int> _expandedModules = {0}; // First module open by default
  late Map<String, dynamic> _path;

  @override
  void initState() {
    super.initState();
    _path = widget.pathData ?? {};

    // Persist path to provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.pathData != null) {
        ref.read(studyPathProvider.notifier).state = widget.pathData;
      } else {
        final saved = ref.read(studyPathProvider);
        if (saved != null) _path = saved;
      }
    });
  }

  List<Map<String, dynamic>> get _modules {
    final raw = _path['modules'];
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(raw as List);
  }

  int get _mastery => (_path['mastery_percentage'] as num?)?.toInt() ?? 0;
  int get _weeks => (_path['estimated_weeks'] as num?)?.toInt() ?? 4;
  String get _summary => _path['summary'] as String? ?? 'Your personalised path is ready.';

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final name = (user?.userMetadata?['full_name'] as String? ?? 'there').split(' ').first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: const SizedBox.shrink(),
            actions: [
              IconButton(
                icon: const Icon(Icons.dashboard_rounded, color: AppColors.white),
                onPressed: () => context.go(AppRoutes.dashboard),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.cardGradient),
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Hey $name, here's your path 🎯",
                      style: AppTextStyles.h3.copyWith(color: AppColors.white.withOpacity(0.85)),
                    ).animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: 8),
                    Text(
                      _summary,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ).animate().fadeIn(delay: 150.ms),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _StatChip(label: '$_mastery%', sublabel: 'Mastery'),
                        const SizedBox(width: 12),
                        _StatChip(label: '$_weeks wks', sublabel: 'Duration'),
                        const SizedBox(width: 12),
                        _StatChip(label: '${_modules.length}', sublabel: 'Modules'),
                      ],
                    ).animate().fadeIn(delay: 250.ms),
                  ],
                ),
              ),
            ),
          ),

          // Focus areas chip row
          if ((_path['focus_areas'] as List?)?.isNotEmpty == true)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Focus Areas', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List<String>.from(_path['focus_areas'] as List)
                          .map((area) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.accentSurface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: AppColors.accent.withOpacity(0.3)),
                                ),
                                child: Text(
                                  area,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.accent,
                                    fontSize: 12,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms),
            ),

          // Modules list
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            sliver: _modules.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 60),
                          const Icon(Icons.error_outline, color: AppColors.grey300, size: 48),
                          const SizedBox(height: 16),
                          Text('Could not load your path.', style: AppTextStyles.h3),
                          const SizedBox(height: 8),
                          Text('Please try again.', style: AppTextStyles.bodyMedium),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => context.go(AppRoutes.levelSelection),
                            child: const Text('Restart'),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index < _modules.length) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: PathModuleCard(
                              module: _modules[index],
                              index: index,
                              isExpanded: _expandedModules.contains(index),
                              onToggle: () => setState(() {
                                if (_expandedModules.contains(index)) {
                                  _expandedModules.remove(index);
                                } else {
                                  _expandedModules.add(index);
                                }
                              }),
                            ),
                          );
                        }
                        return null;
                      },
                      childCount: _modules.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String sublabel;

  const _StatChip({required this.label, required this.sublabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label,
              style: AppTextStyles.h3.copyWith(color: AppColors.white)),
          Text(sublabel,
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.white.withOpacity(0.65))),
        ],
      ),
    );
  }
}


/// Alias used by MainScaffold
typedef StudyPathContent = StudyPathScreen;