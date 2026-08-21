import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/cosmic_logo.dart';
import '../../state/app_state.dart';

class GmailConnectionCompleteScreen extends ConsumerStatefulWidget {
  const GmailConnectionCompleteScreen({super.key});

  @override
  ConsumerState<GmailConnectionCompleteScreen> createState() =>
      _GmailConnectionCompleteScreenState();
}

class _GmailConnectionCompleteScreenState
    extends ConsumerState<GmailConnectionCompleteScreen> {
  bool loading = true;
  String? email;
  String? error;

  @override
  void initState() {
    super.initState();
    _confirmConnection();
  }

  Future<void> _confirmConnection() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final status = await ref.read(apiClientProvider).gmailStatus();
      if (!mounted) return;
      final connected = status['connected'] as bool? ?? false;
      setState(() {
        loading = false;
        email = status['email'] as String?;
        if (!connected) {
          error =
              'Gmail is not connected yet. Return to Google and finish consent.';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'Could not confirm the Gmail connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final connected = !loading && error == null;
    return Scaffold(
      appBar: AppBar(title: const Text('Gmail connection')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CosmicLogo(size: 82),
                const SizedBox(height: 24),
                if (loading)
                  const CircularProgressIndicator()
                else
                  Icon(
                    connected
                        ? Icons.mark_email_read_rounded
                        : Icons.error_outline_rounded,
                    size: 56,
                    color: connected ? AppColors.success : AppColors.danger,
                  ),
                const SizedBox(height: 18),
                Text(
                  loading
                      ? 'Confirming Gmail…'
                      : connected
                      ? 'Gmail connected'
                      : 'Connection not confirmed',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  connected
                      ? '${email ?? 'Your Gmail account'} is ready for the Email Agent.'
                      : error ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 26),
                if (connected)
                  FilledButton.icon(
                    onPressed: () => context.go('/email-agent'),
                    icon: const Icon(Icons.auto_awesome_rounded),
                    label: const Text('Open Email Agent'),
                  )
                else if (!loading)
                  OutlinedButton.icon(
                    onPressed: _confirmConnection,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Check again'),
                  ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => context.go('/connected-apps'),
                  child: const Text('Manage connected apps'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
