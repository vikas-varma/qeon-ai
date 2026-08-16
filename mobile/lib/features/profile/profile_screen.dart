import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/qeon_components.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).asData?.value;
    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : 'Qeon user';
    final email = user?.email ?? '';
    final initials = name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
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
                CircleAvatar(
                  radius: 32,
                  child: Text(
                    initials,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.primary,
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
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) context.go('/sign-in');
            },
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
