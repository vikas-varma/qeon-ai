import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/qeon_components.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.person_outline_rounded,
        'Account',
        'Profile, email and security',
        '/account',
      ),
      (
        Icons.psychology_alt_outlined,
        'Memory & Personalization',
        'Your data, preferences and goals',
        '/memory',
      ),
      (
        Icons.grid_view_rounded,
        'Connected Apps',
        'Google, Calendar, Gmail and more',
        '/connected-apps',
      ),
      (
        Icons.palette_outlined,
        'Appearance',
        'Theme, text and interface style',
        '/appearance',
      ),
      (
        Icons.notifications_none_rounded,
        'Notifications',
        'Customize alerts and reminders',
        '/notifications',
      ),
      (
        Icons.lock_outline_rounded,
        'Privacy & Security',
        'Manage your data and permissions',
        '/privacy',
      ),
    ];

    return QeonPage(
      child: ListView(
        children: [
          QeonCard(
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 32,
                  child: Text(
                    'VP',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vikas Pathipaka',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'vikas@example.com',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Pro',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          QeonCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  SettingsTile(
                    icon: items[i].$1,
                    title: items[i].$2,
                    subtitle: items[i].$3,
                    onTap: () => context.push(items[i].$4),
                  ),
                  if (i < items.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          const QeonCard(
            child: Row(
              children: [
                CircleIcon(
                  icon: Icons.workspace_premium_rounded,
                  color: AppColors.warning,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Qeon AI Pro',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Unlock higher limits and premium agents.',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => context.go('/sign-in'),
            icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
            label: const Text(
              'Sign out',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
