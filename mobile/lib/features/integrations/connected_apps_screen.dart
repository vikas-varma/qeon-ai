import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/qeon_components.dart';

class ConnectedAppsScreen extends StatefulWidget {
  const ConnectedAppsScreen({super.key});

  @override
  State<ConnectedAppsScreen> createState() => _ConnectedAppsScreenState();
}

class _ConnectedAppsScreenState extends State<ConnectedAppsScreen> {
  final _api = ApiClient();
  bool _loading = true;
  bool _connected = false;
  String? _email;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final status = await _api.gmailStatus();
      if (!mounted) return;
      setState(() {
        _connected = status['connected'] as bool? ?? false;
        _email = status['email'] as String?;
        _error = null;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not reach the Qeon AI server.';
        _loading = false;
      });
    }
  }

  Future<void> _connect() async {
    final consented = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const GmailConsentSheet(),
    );
    if (consented != true || !mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final url = await _api.connectGmail();
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw StateError('Could not open Google sign-in.');
      }
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Finish Google consent, return here, then tap Check connection.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst(
          'DioException [bad response]: ',
          '',
        );
        _loading = false;
      });
    }
  }

  Future<void> _disconnect() async {
    setState(() => _loading = true);
    try {
      await _api.disconnectGmail();
      await _refresh();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not disconnect Gmail.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connected Apps')),
      body: QeonPage(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
        child: ListView(
          children: [
            QeonCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleIcon(
                        icon: Icons.mail_rounded,
                        color: Color(0xFFE84D4D),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gmail',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _connected
                                  ? 'Connected as ${_email ?? 'Google user'}'
                                  : 'Summarize email and prepare drafts.',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_loading)
                        const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        TextButton(
                          onPressed: _connected ? _disconnect : _connect,
                          child: Text(_connected ? 'Disconnect' : 'Connect'),
                        ),
                    ],
                  ),
                  if (!_connected && !_loading)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _refresh,
                        child: const Text('Check connection'),
                      ),
                    ),
                  if (_error != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const QeonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What the Email Agent can do',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '• Summarize unread and important messages\n'
                    '• Prioritize mail that needs your attention\n'
                    '• Search messages and answer questions about them\n'
                    '• Prepare replies and follow-up drafts\n'
                    '• Create daily or scheduled inbox briefings',
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Qeon AI asks for approval before sending a message. '
                    'It does not delete mail automatically.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const QeonCard(
              child: SettingsTile(
                icon: Icons.admin_panel_settings_outlined,
                title: 'Your data, your control',
                subtitle:
                    'Review permissions and disconnect access at any time.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GmailConsentSheet extends StatelessWidget {
  const GmailConsentSheet({super.key});

  static final Uri privacyPolicy = Uri.parse('https://qeonai.com/privacy/');

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .9,
      minChildSize: .65,
      maxChildSize: .96,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 22),
          const CircleIcon(
            icon: Icons.mark_email_read_outlined,
            color: Color(0xFFE84D4D),
            size: 58,
          ),
          const SizedBox(height: 18),
          Text(
            'Connect Gmail to Qeon AI',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          const Text(
            'Before Google asks for permission, review how Qeon AI will use '
            'your Gmail data.',
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 22),
          const _ConsentItem(
            icon: Icons.visibility_outlined,
            title: 'Data Qeon AI accesses',
            text:
                'Your connected email address and the Gmail messages, '
                'threads, headers, labels, and drafts needed for features '
                'you request.',
          ),
          const _ConsentItem(
            icon: Icons.auto_awesome_outlined,
            title: 'How that data is used',
            text:
                'To search and summarize mail, identify priorities and '
                'deadlines, answer mailbox questions, and prepare drafts.',
          ),
          const _ConsentItem(
            icon: Icons.security_outlined,
            title: 'Storage and AI processing',
            text:
                'Qeon AI stores an encrypted Google authorization token. '
                'Only content needed for a feature you request is sent to '
                'the configured AI processor. Gmail data is not sold, used '
                'for advertising, or used to train generalized AI models.',
          ),
          const _ConsentItem(
            icon: Icons.approval_outlined,
            title: 'You approve external actions',
            text:
                'Qeon AI may prepare drafts, but it will not send an email '
                'until you review it and explicitly approve sending.',
          ),
          const _ConsentItem(
            icon: Icons.delete_outline_rounded,
            title: 'Disconnect and delete',
            text:
                'You can disconnect Gmail at any time and request deletion '
                'of your Qeon AI account data from the Privacy Policy.',
          ),
          TextButton(
            onPressed: () =>
                launchUrl(privacyPolicy, mode: LaunchMode.externalApplication),
            child: const Text('Read the full Privacy Policy'),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            key: const Key('gmail-consent-continue'),
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('Agree and continue to Google'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not now'),
          ),
        ],
      ),
    );
  }
}

class _ConsentItem extends StatelessWidget {
  const _ConsentItem({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
