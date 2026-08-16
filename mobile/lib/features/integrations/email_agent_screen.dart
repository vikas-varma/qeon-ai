import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/qeon_components.dart';
import '../../state/app_state.dart';

class EmailAgentScreen extends ConsumerStatefulWidget {
  const EmailAgentScreen({super.key});

  @override
  ConsumerState<EmailAgentScreen> createState() => _EmailAgentScreenState();
}

class _EmailAgentScreenState extends ConsumerState<EmailAgentScreen> {
  final _searchController = TextEditingController(text: 'in:inbox');
  bool _loading = true;
  bool _connected = false;
  bool _summaryLoading = false;
  bool _searching = false;
  bool _creatingDraft = false;
  String? _email;
  String? _summary;
  String? _error;
  List<Map<String, dynamic>> _messages = const [];

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    try {
      final status = await ref.read(apiClientProvider).gmailStatus();
      if (!mounted) return;
      setState(() {
        _connected = status['connected'] as bool? ?? false;
        _email = status['email'] as String?;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not check your Gmail connection.';
      });
    }
  }

  Future<void> _summarize() async {
    setState(() {
      _summaryLoading = true;
      _error = null;
    });
    try {
      final result = await ref.read(apiClientProvider).summarizeGmail();
      if (!mounted) return;
      setState(
        () => _summary = result['summary'] as String? ?? 'No summary returned.',
      );
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _error = 'Could not summarize Gmail. Try reconnecting Gmail.',
      );
    } finally {
      if (mounted) setState(() => _summaryLoading = false);
    }
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _searching = true;
      _error = null;
    });
    try {
      final messages = await ref.read(apiClientProvider).searchGmail(query);
      if (!mounted) return;
      setState(() => _messages = messages);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not search Gmail. Try again.');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _compose() async {
    if (_creatingDraft) return;
    final draft = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const GmailComposeSheet(),
    );
    if (draft == null || !mounted) return;

    setState(() {
      _creatingDraft = true;
      _error = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      final created = await api.createGmailDraft(
        to: draft['to']!,
        cc: draft['cc'],
        subject: draft['subject']!,
        body: draft['body']!,
      );
      if (!mounted) return;
      final sent = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => EmailDraftReviewSheet(
          draft: created,
          onApprove: () =>
              api.sendApprovedGmailDraft(created['approval_id'] as String),
        ),
      );
      if (sent == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email sent after your approval.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not create or send the Gmail draft.');
    } finally {
      if (mounted) setState(() => _creatingDraft = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Email Agent')),
      body: QeonPage(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  QeonCard(
                    child: Row(
                      children: [
                        CircleIcon(
                          icon: _connected
                              ? Icons.mark_email_read_rounded
                              : Icons.link_off_rounded,
                          color: _connected
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _connected
                                    ? 'Gmail connected'
                                    : 'Connect Gmail first',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _connected
                                    ? (_email ??
                                          'Ready to work with your inbox')
                                    : 'Grant access before using the Email Agent.',
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/connected-apps'),
                          child: Text(_connected ? 'Manage' : 'Connect'),
                        ),
                      ],
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  ],
                  if (_connected) ...[
                    const SizedBox(height: 18),
                    const SectionTitle('Unread briefing'),
                    QeonCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _summary ??
                                'Summarize unread inbox messages and highlight requests, deadlines, and replies you owe.',
                            style: const TextStyle(height: 1.45),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: _summaryLoading ? null : _summarize,
                            icon: _summaryLoading
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.auto_awesome_rounded),
                            label: Text(
                              _summaryLoading
                                  ? 'Summarizing…'
                                  : 'Summarize unread',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const SectionTitle('Search Gmail'),
                    TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _search(),
                      decoration: InputDecoration(
                        hintText: 'from:person@example.com is:unread',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: IconButton(
                          onPressed: _searching ? null : _search,
                          icon: _searching
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.arrow_forward_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_messages.isEmpty)
                      const Text(
                        'Run a search to see matching messages.',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    for (final message in _messages) ...[
                      QeonCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    message['subject'] as String? ??
                                        '(no subject)',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                if (message['unread'] == true)
                                  const Icon(
                                    Icons.circle,
                                    color: AppColors.primary,
                                    size: 9,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message['sender'] as String? ?? '',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(message['snippet'] as String? ?? ''),
                          ],
                        ),
                      ),
                      const SizedBox(height: 9),
                    ],
                    const SizedBox(height: 12),
                    GradientButton(
                      label: _creatingDraft
                          ? 'Creating draft…'
                          : 'Compose a draft',
                      icon: Icons.edit_note_rounded,
                      onPressed: _compose,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Qeon AI creates a Gmail draft first. Nothing is sent until you review it and approve Send.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class GmailComposeSheet extends StatefulWidget {
  const GmailComposeSheet({super.key});

  @override
  State<GmailComposeSheet> createState() => _GmailComposeSheetState();
}

class _GmailComposeSheetState extends State<GmailComposeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _to = TextEditingController();
  final _cc = TextEditingController();
  final _subject = TextEditingController();
  final _body = TextEditingController();

  @override
  void dispose() {
    _to.dispose();
    _cc.dispose();
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Gmail draft',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _to,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'To'),
                validator: (value) => value == null || !value.contains('@')
                    ? 'Enter a recipient email address'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _cc,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Cc (optional)'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _subject,
                decoration: const InputDecoration(labelText: 'Subject'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a subject'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _body,
                minLines: 6,
                maxLines: 12,
                decoration: const InputDecoration(labelText: 'Message'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a message'
                    : null,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  Navigator.pop(context, {
                    'to': _to.text.trim(),
                    'cc': _cc.text.trim(),
                    'subject': _subject.text.trim(),
                    'body': _body.text.trim(),
                  });
                },
                icon: const Icon(Icons.drafts_outlined),
                label: const Text('Create draft for review'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmailDraftReviewSheet extends StatefulWidget {
  const EmailDraftReviewSheet({
    super.key,
    required this.draft,
    required this.onApprove,
  });

  final Map<String, dynamic> draft;
  final Future<Object?> Function() onApprove;

  @override
  State<EmailDraftReviewSheet> createState() => _EmailDraftReviewSheetState();
}

class _EmailDraftReviewSheetState extends State<EmailDraftReviewSheet> {
  bool _reviewed = false;
  bool _sending = false;
  String? _error;

  Future<void> _send() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await widget.onApprove();
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = 'Sending failed. The draft remains unsent in Gmail.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .9,
      minChildSize: .65,
      maxChildSize: .96,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Text(
            'Review before sending',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'This is the final approval step. Check every field carefully.',
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 18),
          QeonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DraftField(
                  label: 'To',
                  value: widget.draft['to'] as String? ?? '',
                ),
                if ((widget.draft['cc'] as String?)?.isNotEmpty == true)
                  _DraftField(label: 'Cc', value: widget.draft['cc'] as String),
                _DraftField(
                  label: 'Subject',
                  value: widget.draft['subject'] as String? ?? '',
                ),
                const Divider(),
                Text(widget.draft['body'] as String? ?? ''),
              ],
            ),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            key: const Key('email-send-review-checkbox'),
            value: _reviewed,
            onChanged: _sending
                ? null
                : (value) => setState(() => _reviewed = value ?? false),
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'I reviewed the recipients, subject, and message and approve sending this email.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: AppColors.danger)),
          const SizedBox(height: 8),
          FilledButton.icon(
            key: const Key('email-send-approved-button'),
            onPressed: _reviewed && !_sending ? _send : null,
            icon: _sending
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_rounded),
            label: Text(_sending ? 'Sending…' : 'Approve and send'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
            ),
          ),
          TextButton(
            onPressed: _sending ? null : () => Navigator.pop(context, false),
            child: const Text('Keep as draft'),
          ),
        ],
      ),
    );
  }
}

class _DraftField extends StatelessWidget {
  const _DraftField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 62,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
