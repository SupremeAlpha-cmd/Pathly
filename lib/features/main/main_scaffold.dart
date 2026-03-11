import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../dashboard/screens/dashboard_screen.dart';
import '../study_path/screens/study_path_screen.dart';
import '../progress/screens/progress_screen.dart';
import '../profile/screens/profile_screen.dart';

final mainNavIndexProvider = StateProvider<int>((ref) => 0);

class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  static final List<Widget> _screens = [
    const DashboardContent(),
    const StudyPathContent(),
    const ProgressScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(mainNavIndexProvider);
    final user = ref.watch(currentUserProvider);
    final firstName = (user?.userMetadata?['full_name'] as String? ?? 'there')
        .split(' ')
        .first;
    final fullName = user?.userMetadata?['full_name'] as String? ?? 'User';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (currentIndex != 0) {
          ref.read(mainNavIndexProvider.notifier).state = 0;
          return;
        }
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Exit Pathly?'),
            content: const Text('Are you sure you want to exit?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Stay'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Exit', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
        if (shouldExit == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        drawer: _buildDrawer(context, ref, fullName, firstName),
        body: _screens[currentIndex],
        bottomNavigationBar: _buildBottomNav(context, ref, currentIndex),
      ),
    );
  }

  Widget _buildBottomNav(
      BuildContext context, WidgetRef ref, int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.dark.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  index: 0,
                  currentIndex: currentIndex,
                  onTap: () =>
                      ref.read(mainNavIndexProvider.notifier).state = 0),
              _NavItem(
                  icon: Icons.route_rounded,
                  label: 'My Path',
                  index: 1,
                  currentIndex: currentIndex,
                  onTap: () =>
                      ref.read(mainNavIndexProvider.notifier).state = 1),
              _NavItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Progress',
                  index: 2,
                  currentIndex: currentIndex,
                  onTap: () =>
                      ref.read(mainNavIndexProvider.notifier).state = 2),
              _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  index: 3,
                  currentIndex: currentIndex,
                  onTap: () =>
                      ref.read(mainNavIndexProvider.notifier).state = 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(
      BuildContext context, WidgetRef ref, String fullName, String firstName) {
    final user = ref.read(currentUserProvider);
    final initial = firstName[0].toUpperCase();

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              decoration: const BoxDecoration(gradient: AppColors.cardGradient),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: AppTextStyles.displayMedium.copyWith(
                          color: AppColors.white,
                          fontSize: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    fullName,
                    style: AppTextStyles.h2.copyWith(color: AppColors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Nav items
            _DrawerItem(
                icon: Icons.home_rounded,
                label: 'Home',
                onTap: () {
                  Navigator.pop(context);
                  ref.read(mainNavIndexProvider.notifier).state = 0;
                }),
            _DrawerItem(
                icon: Icons.route_rounded,
                label: 'My Path',
                onTap: () {
                  Navigator.pop(context);
                  ref.read(mainNavIndexProvider.notifier).state = 1;
                }),
            _DrawerItem(
                icon: Icons.bar_chart_rounded,
                label: 'Progress',
                onTap: () {
                  Navigator.pop(context);
                  ref.read(mainNavIndexProvider.notifier).state = 2;
                }),
            _DrawerItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                onTap: () {
                  Navigator.pop(context);
                  ref.read(mainNavIndexProvider.notifier).state = 3;
                }),

            const Divider(height: 32),

            _DrawerItem(
              icon: Icons.refresh_rounded,
              label: 'Retake Diagnostic',
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.levelSelection);
              },
            ),
            _DrawerItem(
              icon: Icons.help_outline_rounded,
              label: 'Help & Feedback',
              onTap: () => Navigator.pop(context),
            ),

            const Spacer(),

            const Divider(),

            _DrawerItem(
              icon: Icons.logout_rounded,
              label: 'Log Out',
              color: AppColors.error,
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authNotifierProvider.notifier).signOut();
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  bool get _isSelected => index == currentIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _isSelected ? AppColors.primarySurface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: _isSelected ? AppColors.primary : AppColors.grey300,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: _isSelected ? AppColors.primary : AppColors.grey300,
                fontWeight: _isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.dark;
    return ListTile(
      leading: Icon(icon, color: c, size: 22),
      title: Text(label, style: AppTextStyles.labelLarge.copyWith(color: c)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      dense: true,
    );
  }
}
