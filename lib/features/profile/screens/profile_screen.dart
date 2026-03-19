import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import 'package:pathly/features/auth/providers/auth_provider.dart';
import 'package:pathly/core/services/supabase_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final fullName = user?.userMetadata?['full_name'] as String? ?? 'User';
    final email = user?.email ?? '';
    final initial = fullName[0].toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile', style: AppTextStyles.displayMedium)
                  .animate()
                  .fadeIn(),
              const SizedBox(height: 28),

              // Avatar + name card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: AppTextStyles.displayMedium.copyWith(
                            color: AppColors.white,
                            fontSize: 36,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      fullName,
                      style: AppTextStyles.h1.copyWith(color: AppColors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.white.withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 28),

              // Account section
              _SectionHeader(title: 'Account'),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.person_outline_rounded,
                label: 'Full Name',
                trailing: fullName,
              ),
              _SettingsTile(
                icon: Icons.email_outlined,
                label: 'Email',
                trailing: email,
              ),
              _SettingsTile(
                icon: Icons.lock_outline_rounded,
                label: 'Change Password',
                onTap: () => _showChangePasswordDialog(context, ref),
              ),

              const SizedBox(height: 24),

              // Learning section
              _SectionHeader(title: 'Learning'),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.refresh_rounded,
                label: 'Retake Diagnostic',
                onTap: () => context.push(AppRoutes.levelSelection),
              ),
              _SettingsTile(
                icon: Icons.route_rounded,
                label: 'View My Path',
                onTap: () => context.push(AppRoutes.studyPath),
              ),

              const SizedBox(height: 24),

              // About section
              _SectionHeader(title: 'About'),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                label: 'App Version',
                trailing: '1.0.0',
              ),
              _SettingsTile(
                icon: Icons.help_outline_rounded,
                label: 'Help & Feedback',
                onTap: () {},
              ),

              const SizedBox(height: 32),

              // Log out button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authNotifierProvider.notifier).signOut();
                  },
                  icon:
                      const Icon(Icons.logout_rounded, color: AppColors.error),
                  label: Text(
                    'Log Out',
                    style: AppTextStyles.labelLarge
                        .copyWith(color: AppColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Change Password', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            Text('We\'ll send a reset link to your email.',
                style: AppTextStyles.bodyMedium),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final user = ref.read(currentUserProvider);
                if (user?.email != null) {
                  await ref
                      .read(authNotifierProvider.notifier)
                      .resetPassword(user!.email!);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Reset link sent to your email!')),
                    );
                  }
                }
              },
              child: const Text('Send Reset Link'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: AppTextStyles.labelSmall.copyWith(
        color: AppColors.grey300,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.dark.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(label, style: AppTextStyles.labelMedium),
        trailing: trailing != null
            ? Text(trailing!,
                style:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.grey300))
            : onTap != null
                ? const Icon(Icons.chevron_right_rounded,
                    color: AppColors.grey300)
                : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
