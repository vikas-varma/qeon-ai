import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/qeon_components.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Security')),
      body: QeonPage(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
        child: ListView(
          children: const [
            QeonCard(
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.key_rounded,
                    title: 'App permissions',
                    subtitle: 'Microphone, files and notifications',
                  ),
                  Divider(),
                  SettingsTile(
                    icon: Icons.link_off_rounded,
                    title: 'Connected account access',
                    subtitle: 'Review OAuth permissions',
                  ),
                  Divider(),
                  SettingsTile(
                    icon: Icons.devices_rounded,
                    title: 'Active sessions',
                    subtitle: 'Manage signed-in devices',
                  ),
                  Divider(),
                  SettingsTile(
                    icon: Icons.download_rounded,
                    title: 'Export your data',
                    subtitle: 'Request a copy of your information',
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            QeonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleIcon(
                        icon: Icons.verified_user_outlined,
                        color: AppColors.success,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Security principles',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14),
                  Text(
                    '• Important external actions require confirmation.\n• Connected-app scopes should remain minimal.\n• Secret keys belong only on the backend.',
                    style: TextStyle(height: 1.6, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
