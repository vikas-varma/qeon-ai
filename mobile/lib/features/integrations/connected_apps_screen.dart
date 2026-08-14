import 'dart:async';

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
      if (mounted) setState(() { _error = 'Could not reach the Qeon AI server.'; _loading = false; });
    }
  }

  Future<void> _connect() async {
    setState(() { _loading = true; _error = null; });
    try {
      final url = await _api.connectGmail();
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw StateError('Could not open Google sign-in.');
      }
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Finish Google consent, then tap “Check connection”.')));
    } catch (error) {
      if (mounted) setState(() { _error = error.toString().replaceFirst('DioException [bad response]: ', ''); _loading = false; });
    }
  }

  Future<void> _disconnect() async {
    setState(() => _loading = true);
    try {
      await _api.disconnectGmail();
      await _refresh();
    } catch (_) {
      if (mounted) setState(() { _error = 'Could not disconnect Gmail.'; _loading = false; });
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
                  Row(children: [
                    const CircleIcon(icon: Icons.mail_rounded, color: Color(0xFFE84D4D)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Gmail', style: TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text(_connected ? 'Connected as ${_email ?? 'Google user'}' : 'Summarize email and prepare drafts.', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ])),
                    if (_loading) const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2))
                    else TextButton(onPressed: _connected ? _disconnect : _connect, child: Text(_connected ? 'Disconnect' : 'Connect')),
                  ]),
                  if (!_connected && !_loading) Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _refresh, child: const Text('Check connection'))),
                  if (_error != null) Align(alignment: Alignment.centerLeft, child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const QeonCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('What the Email Agent can do', style: TextStyle(fontWeight: FontWeight.w800)),
              SizedBox(height: 10),
              Text('• Summarize unread and important messages\n• Prioritize mail that needs your attention\n• Search messages and answer questions about them\n• Prepare replies and follow-up drafts\n• Create daily or scheduled inbox briefings'),
              SizedBox(height: 10),
              Text('Qeon AI asks for approval before sending a message. It does not delete mail automatically.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ])),
            const SizedBox(height: 12),
            const QeonCard(child: SettingsTile(icon: Icons.admin_panel_settings_outlined, title: 'Your data, your control', subtitle: 'Google shows the requested permissions. Disconnect and revoke access at any time.')),
          ],
        ),
      ),
    );
  }
}
