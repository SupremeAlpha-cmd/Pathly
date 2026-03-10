import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import 'lesson_tile.dart';

class PathModuleCard extends StatefulWidget {
  final Map<String, dynamic> module;
  final int index;
  final bool isExpanded;
  final VoidCallback onToggle;

  const PathModuleCard({
    super.key,
    required this.module,
    required this.index,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  State<PathModuleCard> createState() => _PathModuleCardState();
}

class _PathModuleCardState extends State<PathModuleCard> {
  bool get _isWeakArea => widget.module['is_weak_area'] == true;

  @override
  Widget build(BuildContext context) {
    final lessons = List<Map<String, dynamic>>.from(
      widget.module['lessons'] as List? ?? [],
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isWeakArea ? AppColors.warning.withOpacity(0.4) : AppColors.grey100,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.dark.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Module header
          InkWell(
            onTap: widget.onToggle,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  // Module number
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _isWeakArea
                          ? AppColors.warning.withOpacity(0.12)
                          : AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.index + 1}',
                        style: AppTextStyles.h3.copyWith(
                          color: _isWeakArea ? AppColors.warning : AppColors.primary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.module['title'] as String? ?? 'Module',
                                style: AppTextStyles.h3,
                              ),
                            ),
                            if (_isWeakArea)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Focus area',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.warning,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${lessons.length} lessons',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  AnimatedRotation(
                    turns: widget.isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.grey300,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Lessons list (expanded)
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: widget.isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              children: [
                const Divider(height: 1),
                ...lessons.asMap().entries.map((entry) {
                  return LessonTile(
                    lesson: entry.value,
                    index: entry.key,
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 100 * widget.index))
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
  }
}