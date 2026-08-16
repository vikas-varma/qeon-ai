import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/qeon_components.dart';
import '../../state/app_state.dart';

class PrivacyScreen extends ConsumerStatefulWidget {
  const PrivacyScreen({super.key});

  @override
  ConsumerState<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends ConsumerState<PrivacyScreen> {
  bool _deleting = false;

  Future<void> _deleteData() async {
    var confirmation = '';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Delete all Qeon AI data?'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This removes your tasks, memories, conversations, audit history, and connected Gmail credential. It cannot be undone.',
                ),
                const SizedBox(height: 14),
                const Text('Type DELETE to confirm.'),
                const SizedBox(height: 8),
                TextField(
                  key: const Key('delete-data-confirmation-field'),
                  onChanged: (value) =>
                      setDialogState(() => confirmation = value.trim()),
                  decoration: const InputDecoration(hintText: 'DELETE'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              key: const Key('delete-data-confirm-button'),
              onPressed: confirmation == 'DELETE'
                  ? () => Navigator.pop(dialogContext, true)
                  : null,
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              child: const Text('Delete my data'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await ref.read(apiClientProvider).deleteMyData();
      ref.invalidate(tasksProvider);
      ref.invalidate(memoriesProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your Qeon AI data was deleted.')),
      );
      context.go('/onboarding');
    } catch (_) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data deletion failed. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Security')),
      body: QeonPage(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
        child: ListView(
          children: [
            QeonCard(
              child: Column(
                children: [
                  const SettingsTile(
                    icon: Icons.key_rounded,
                    title: 'App permissions',
                    subtitle: 'Microphone, files and notifications',
                    trailing: Icon(Icons.info_outline_rounded),
                  ),
                  const Divider(),
                  SettingsTile(
                    icon: Icons.link_off_rounded,
                    title: 'Connected account access',
                    subtitle: 'Review or disconnect Gmail access',
                    onTap: () => context.push('/connected-apps'),
                  ),
                  const Divider(),
                  const SettingsTile(
                    icon: Icons.devices_rounded,
                    title: 'Active sessions',
                    subtitle: 'Available after Firebase sign-in is enabled',
                    trailing: Icon(Icons.info_outline_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const QeonCard(
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
                    '• Important external actions require confirmation.\n'
                    '• Connected-app scopes remain limited to requested features.\n'
                    '• Secret keys stay only on the backend.',
                    style: TextStyle(height: 1.6, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            QeonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Delete Qeon AI data',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Permanently remove your stored app data and revoke the connected Gmail credential.',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    key: const Key('delete-account-data-button'),
                    onPressed: _deleting ? null : _deleteData,
                    icon: _deleting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_forever_outlined),
                    label: Text(_deleting ? 'Deleting…' : 'Delete my data'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                    ),
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
