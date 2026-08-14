import 'package:flutter/material.dart';

import '../../core/widgets/qeon_components.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool taskUpdates = true;
  bool reminders = true;
  bool productNews = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: QeonPage(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
        child: ListView(
          children: [
            QeonCard(
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: taskUpdates,
                    onChanged: (v) => setState(() => taskUpdates = v),
                    title: const Text(
                      'Task updates',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text(
                      'Completion, failure and approval alerts.',
                    ),
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: reminders,
                    onChanged: (v) => setState(() => reminders = v),
                    title: const Text(
                      'Reminders',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text(
                      'Scheduled task and calendar reminders.',
                    ),
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: productNews,
                    onChanged: (v) => setState(() => productNews = v),
                    title: const Text(
                      'Product updates',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text(
                      'New Qeon AI capabilities and announcements.',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const QeonCard(
              child: SettingsTile(
                icon: Icons.schedule_rounded,
                title: 'Quiet hours',
                subtitle: '10:00 PM–6:00 AM',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
