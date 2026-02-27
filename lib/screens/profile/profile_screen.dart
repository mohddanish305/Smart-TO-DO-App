// lib/screens/profile/profile_screen.dart
// Premium minimalist profile: avatar, stats, dark mode, themes, privacy, logout

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_themes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/theme_provider.dart';
import '../auth/auth_screen.dart';
import '../privacy/privacy_policy_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final tasks = context.watch<TaskProvider>();
    final themeP = context.watch<ThemeProvider>();
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final surface = Theme.of(context).colorScheme.surface;
    final primary = Theme.of(context).colorScheme.primary;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textMuted = isDark ? const Color(0xFF8A8A8A) : const Color(0xFFAAAAAA);
    final border = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8);
    final user = auth.user;

    final total = tasks.allTasks.length;
    final done = tasks.completedTasks.length;
    final pending = tasks.pendingTasks.length;
    final rate = total == 0 ? 0.0 : done / total;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile',
                      style: GoogleFonts.dmSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Avatar Card ────────────────────────────
                    _Card(
                      isDark: isDark,
                      border: border,
                      surface: surface,
                      child: Row(
                        children: [
                          _Avatar(
                            initials: user?.initials ?? '?',
                            primary: primary,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? 'User',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  user?.email ?? 'Not signed in',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    color: textMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Stats ─────────────────────────────────
                    Row(children: [
                      Expanded(child: _StatBox(label: 'Total', value: '$total', icon: Icons.list_rounded, isDark: isDark, border: border, surface: surface, primary: primary, textPrimary: textPrimary, textMuted: textMuted)),
                      const SizedBox(width: 10),
                      Expanded(child: _StatBox(label: 'Done', value: '$done', icon: Icons.check_circle_outline_rounded, isDark: isDark, border: border, surface: surface, primary: const Color(0xFF10B981), textPrimary: textPrimary, textMuted: textMuted)),
                      const SizedBox(width: 10),
                      Expanded(child: _StatBox(label: 'Pending', value: '$pending', icon: Icons.hourglass_bottom_rounded, isDark: isDark, border: border, surface: surface, primary: const Color(0xFFF59E0B), textPrimary: textPrimary, textMuted: textMuted)),
                    ]),

                    const SizedBox(height: 16),

                    // ── Progress ──────────────────────────────
                    _Card(
                      isDark: isDark,
                      border: border,
                      surface: surface,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Completion Rate',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: textMuted,
                                ),
                              ),
                              Text(
                                '${(rate * 100).toStringAsFixed(0)}%',
                                style: GoogleFonts.dmSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: rate.clamp(0.0, 1.0),
                              backgroundColor: border,
                              color: primary,
                              minHeight: 7,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$done of $total tasks completed',
                            style: GoogleFonts.dmSans(
                                fontSize: 12, color: textMuted),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    _SectionHeader(label: 'Appearance', textMuted: textMuted),
                    const SizedBox(height: 10),

                    // ── Dark Mode Toggle ──────────────────────
                    _Card(
                      isDark: isDark,
                      border: border,
                      surface: surface,
                      child: Row(
                        children: [
                          _IconBox(
                            icon: isDark
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                            color: primary,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Dark Mode',
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: textPrimary,
                              ),
                            ),
                          ),
                          Switch(
                            value: themeP.isDark,
                            onChanged: (_) => themeP.toggleDark(),
                            activeColor: primary,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Theme Picker ──────────────────────────
                    _Card(
                      isDark: isDark,
                      border: border,
                      surface: surface,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _IconBox(icon: Icons.palette_outlined, color: primary),
                              const SizedBox(width: 14),
                              Text(
                                'Theme',
                                style: GoogleFonts.dmSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _ThemePicker(
                            selectedIndex: themeP.themeIndex,
                            isDark: isDark,
                            border: border,
                            onSelect: (i) => themeP.setTheme(i),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    _SectionHeader(label: 'Support', textMuted: textMuted),
                    const SizedBox(height: 10),

                    // ── Privacy Policy ────────────────────────
                    _ActionTile(
                      icon: Icons.privacy_tip_outlined,
                      label: 'Privacy Policy',
                      isDark: isDark,
                      border: border,
                      surface: surface,
                      primary: primary,
                      textPrimary: textPrimary,
                      textMuted: textMuted,
                      hasChevron: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _ActionTile(
                      icon: Icons.info_outline_rounded,
                      label: 'App Version',
                      subtitle: AppConstants.appVersion,
                      isDark: isDark,
                      border: border,
                      surface: surface,
                      primary: primary,
                      textPrimary: textPrimary,
                      textMuted: textMuted,
                    ),

                    const SizedBox(height: 24),
                    _SectionHeader(label: 'Account', textMuted: textMuted),
                    const SizedBox(height: 10),

                    // ── Sign Out ──────────────────────────────
                    Consumer2<AuthProvider, TaskProvider>(
                      builder: (ctx, authP, taskP, _) => _ActionTile(
                        icon: Icons.logout_rounded,
                        label: 'Sign Out',
                        isDark: isDark,
                        border: border,
                        surface: surface,
                        primary: const Color(0xFFE63946),
                        textPrimary: const Color(0xFFE63946),
                        textMuted: textMuted,
                        onTap: () => _confirmLogout(ctx, authP, taskP),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(
      BuildContext context, AuthProvider auth, TaskProvider taskP) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sign out?',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
        content: Text('You will be signed out of your account.',
            style: GoogleFonts.dmSans()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: GoogleFonts.dmSans())),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                TextButton.styleFrom(foregroundColor: const Color(0xFFE63946)),
            child: Text('Sign out', style: GoogleFonts.dmSans()),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      taskP.reset();
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

// ─────────────────────────────────────────────────────────
// Subwidgets
// ─────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final Color border;
  final Color surface;

  const _Card({
    required this.child,
    required this.isDark,
    required this.border,
    required this.surface,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: border),
      ),
      child: child,
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initials;
  final Color primary;

  const _Avatar({required this.initials, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border:
            Border.all(color: primary.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: primary,
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isDark;
  final Color border;
  final Color surface;
  final Color primary;
  final Color textPrimary;
  final Color textMuted;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
    required this.border,
    required this.surface,
    required this.primary,
    required this.textPrimary,
    required this.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Icon(icon, color: primary, size: 22),
          const SizedBox(height: 8),
          Text(value,
              style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: textPrimary)),
          Text(label,
              style:
                  GoogleFonts.dmSans(fontSize: 12, color: textMuted)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color textMuted;

  const _SectionHeader({required this.label, required this.textMuted});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
        color: textMuted,
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconBox({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool isDark;
  final Color border;
  final Color surface;
  final Color primary;
  final Color textPrimary;
  final Color textMuted;
  final bool hasChevron;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.border,
    required this.surface,
    required this.primary,
    required this.textPrimary,
    required this.textMuted,
    this.subtitle,
    this.hasChevron = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: surface,
          borderRadius:
              BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            _IconBox(icon: icon, color: primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: textPrimary)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: GoogleFonts.dmSans(
                            fontSize: 12, color: textMuted)),
                ],
              ),
            ),
            if (hasChevron)
              Icon(Icons.chevron_right_rounded, size: 20, color: textMuted),
          ],
        ),
      ),
    );
  }
}

class _ThemePicker extends StatelessWidget {
  final int selectedIndex;
  final bool isDark;
  final Color border;
  final ValueChanged<int> onSelect;

  const _ThemePicker({
    required this.selectedIndex,
    required this.isDark,
    required this.border,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(AppThemes.themes.length, (i) {
        final theme = AppThemes.themes[i];
        final isSelected = selectedIndex == i;

        return GestureDetector(
          onTap: () => onSelect(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: (MediaQuery.of(context).size.width - 40 - 32 - 40) /
                    5 -
                2,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? theme.primary
                    : border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 14)
                      : null,
                ),
                const SizedBox(height: 4),
                Text(
                  theme.name.split(' ').first,
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFF8A8A8A)
                        : const Color(0xFF555555),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
