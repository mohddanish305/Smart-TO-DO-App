// lib/screens/privacy/privacy_policy_screen.dart
// Full Privacy Policy screen — scrollable, structured, professional

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = isDark ? const Color(0xFF8A8A8A) : const Color(0xFF555555);
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
        children: [
          // Last updated
          Text(
            'Last updated: February 27, 2026',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 28),

          _Section(
            title: '1. Introduction',
            icon: Icons.info_outline_rounded,
            primary: primary,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            content:
                'Smart To-Do ("the App") is a personal productivity application built with your privacy as our highest priority. We believe in minimal data collection and maximum transparency. This Privacy Policy explains what information we collect (if any), how we use it, and your rights as a user.',
          ),

          _Section(
            title: '2. Data Collection',
            icon: Icons.data_usage_outlined,
            primary: primary,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            content:
                'Smart To-Do collects minimal data:\n\n'
                '• Task data (titles, descriptions, categories, due dates, completion status) — stored only on your device.\n\n'
                '• Account information (name, email address) if you choose to sign in with Google or Email — used solely to personalize your experience.\n\n'
                '• App preferences (dark mode, theme selection) — stored locally on your device.\n\n'
                'We do NOT collect analytics, behavioral data, location data, or any other personal information.',
          ),

          _Section(
            title: '3. Local Storage Usage',
            icon: Icons.storage_outlined,
            primary: primary,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            content:
                'All of your task data and app preferences are stored exclusively on your local device using SQLite (for tasks) and SharedPreferences (for settings). Your data:\n\n'
                '• Never leaves your device without your explicit consent.\n\n'
                '• Is not backed up to any remote server by the App itself.\n\n'
                '• Remains available offline at all times.\n\n'
                '• Is deleted when you uninstall the App or choose to clear app data.',
          ),

          _Section(
            title: '4. No Third-Party Sharing',
            icon: Icons.shield_outlined,
            primary: primary,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            content:
                'We do not sell, trade, rent, or share your personal information with any third parties. Specifically:\n\n'
                '• No advertising networks receive your data.\n\n'
                '• No analytics services track your in-app behavior.\n\n'
                '• No data brokers or marketing platforms receive your information.\n\n'
                'If you use Google Sign-In, Google\'s own privacy policy governs how Google handles your credentials. We receive only your name and email address.',
          ),

          _Section(
            title: '5. Your Rights',
            icon: Icons.verified_user_outlined,
            primary: primary,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            content:
                'You have full control over your data:\n\n'
                '• Access — You can view all your tasks and account information within the App at any time.\n\n'
                '• Deletion — You can delete individual tasks, or clear all data by signing out or uninstalling the App.\n\n'
                '• Portability — All your data is stored locally on your device and belongs entirely to you.\n\n'
                '• Correction — You can edit any task or account information directly within the App.',
          ),

          _Section(
            title: '6. Security',
            icon: Icons.lock_outline_rounded,
            primary: primary,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            content:
                'We take the security of your data seriously. Your data is stored using industry-standard local database mechanisms protected by Android\'s built-in application sandboxing. Only the Smart To-Do app can access its own local data.',
          ),

          _Section(
            title: '7. Changes to This Policy',
            icon: Icons.history_rounded,
            primary: primary,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            content:
                'We may update this Privacy Policy from time to time. We will notify you of any changes by updating the "Last updated" date at the top of this page. Continued use of the App after any changes constitutes your acceptance of the updated policy.',
          ),

          _Section(
            title: '8. Contact Information',
            icon: Icons.mail_outline_rounded,
            primary: primary,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            content:
                'If you have any questions, concerns, or requests regarding this Privacy Policy, please contact us:\n\n'
                'Email: support@smarttodo.app\n\n'
                'We aim to respond to all privacy inquiries within 48 hours.',
          ),

          const SizedBox(height: 16),
          Divider(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8)),
          const SizedBox(height: 16),
          Text(
            '© 2026 Smart To-Do. All rights reserved.',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color primary;
  final Color textPrimary;
  final Color textSecondary;
  final String content;

  const _Section({
    required this.title,
    required this.icon,
    required this.primary,
    required this.textPrimary,
    required this.textSecondary,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: primary, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              height: 1.7,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
