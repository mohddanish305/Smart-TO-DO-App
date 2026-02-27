// lib/screens/settings/settings_screen.dart
// App settings: theme toggle, logout, app info

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/theme_provider.dart';
import '../auth/auth_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                left: AppConstants.spacingM,
                right: AppConstants.spacingM,
                bottom: 24,
              ),
              child: Text('Settings',
                  style: AppTextStyles.headingLarge(isDark)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Account ───────────────────────────────
                _sectionLabel('Account', isDark),
                const SizedBox(height: 8),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) => _SettingsTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.accentLight,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          auth.user?.initials ?? '?',
                          style: AppTextStyles.labelMedium(false).copyWith(
                            color: AppColors.accentDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    title: auth.user?.name ?? 'User',
                    subtitle: auth.user?.email ?? '',
                    isDark: isDark,
                  ),
                ),

                const SizedBox(height: AppConstants.spacingL),

                // ── Appearance ────────────────────────────
                _sectionLabel('Appearance', isDark),
                const SizedBox(height: 8),
                Consumer<ThemeProvider>(
                  builder: (context, themeP, _) => _SettingsTile(
                    leading: _iconBox(
                        isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        isDark),
                    title: 'Dark Mode',
                    isDark: isDark,
                    trailing: Switch(
                      value: themeP.isDark,
                      onChanged: (_) => themeP.toggleTheme(),
                      activeColor: AppColors.accent,
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.spacingL),

                // ── About ─────────────────────────────────
                _sectionLabel('About', isDark),
                const SizedBox(height: 8),
                _SettingsTile(
                  leading: _iconBox(Icons.info_outline_rounded, isDark),
                  title: 'App Version',
                  subtitle: AppConstants.appVersion,
                  isDark: isDark,
                ),
                const SizedBox(height: 2),
                _SettingsTile(
                  leading: _iconBox(Icons.privacy_tip_outlined, isDark),
                  title: 'Privacy Policy',
                  isDark: isDark,
                  trailing: const Icon(Icons.chevron_right_rounded, size: 18),
                  onTap: () async {
                    final uri = Uri.parse('https://policies.google.com/privacy'); // Replace with actual Privacy Policy
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),

                const SizedBox(height: AppConstants.spacingL),

                // ── Logout ────────────────────────────────
                _sectionLabel('Account', isDark),
                const SizedBox(height: 8),
                Consumer2<AuthProvider, TaskProvider>(
                  builder: (context, auth, taskP, _) => _SettingsTile(
                    leading: _iconBox(
                        Icons.logout_rounded, isDark,
                        color: AppColors.error),
                    title: 'Sign out',
                    titleColor: AppColors.error,
                    isDark: isDark,
                    onTap: () => _confirmLogout(context, auth, taskP),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.labelSmall(isDark).copyWith(letterSpacing: 0.8),
      ),
    );
  }

  Widget _iconBox(IconData icon, bool isDark, {Color? color}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: (color ?? AppColors.accent).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      ),
      child: Icon(icon,
          size: 18, color: color ?? AppColors.accent),
    );
  }

  Future<void> _confirmLogout(
      BuildContext context,
      AuthProvider auth,
      TaskProvider taskProvider,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will be signed out of your account.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      taskProvider.reset();
      await auth.signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
              (_) => false,
        );
      }
    }
  }
}

// ── Settings Tile ─────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final bool isDark;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  const _SettingsTile({
    required this.leading,
    required this.title,
    required this.isDark,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.headingSmall(isDark).copyWith(
                      color: titleColor,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: AppTextStyles.bodySmall(isDark)),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
