import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/qeon_components.dart';
import '../../state/app_state.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _activity = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final activity = await ref.read(apiClientProvider).listActivity();
      if (!mounted) return;
      setState(() {
        _activity = activity;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load your activity.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security activity'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: QeonPage(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!),
                    TextButton(onPressed: _load, child: const Text('Retry')),
                  ],
                ),
              )
            : _activity.isEmpty
            ? const Center(
                child: Text(
                  'No recorded activity yet.',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              )
            : ListView.separated(
                itemCount: _activity.length,
                separatorBuilder: (_, _) => const SizedBox(height: 9),
                itemBuilder: (context, index) =>
                    ActivityEntry(activity: _activity[index]),
              ),
      ),
    );
  }
}

class ActivityEntry extends StatelessWidget {
  const ActivityEntry({super.key, required this.activity});

  final Map<String, dynamic> activity;

  static const _labels = {
    'task.created': 'Task created',
    'task.deleted': 'Task deleted',
    'memory.created': 'Memory saved',
    'memory.deleted': 'Memory deleted',
    'memory.cleared': 'All memories cleared',
    'gmail.connected': 'Gmail connected',
    'gmail.disconnected': 'Gmail disconnected',
    'gmail.draft_created': 'Gmail draft created',
    'gmail.draft_approved_and_sent': 'Email approved and sent',
  };

  @override
  Widget build(BuildContext context) {
    final action = activity['action'] as String? ?? 'activity';
    final timestamp = DateTime.tryParse(
      activity['created_at'] as String? ?? '',
    );
    return QeonCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleIcon(icon: _icon(action), color: _color(action), size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _labels[action] ?? action,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  timestamp == null
                      ? 'Time unavailable'
                      : _formatTime(timestamp),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static IconData _icon(String action) {
    if (action.startsWith('gmail.')) return Icons.mark_email_read_outlined;
    if (action.startsWith('memory.')) return Icons.psychology_alt_outlined;
    return Icons.task_alt_rounded;
  }

  static Color _color(String action) {
    if (action.contains('deleted') || action.contains('cleared')) {
      return AppColors.danger;
    }
    if (action.contains('sent') || action.contains('connected')) {
      return AppColors.success;
    }
    return AppColors.primary;
  }

  static String _formatTime(DateTime value) {
    final local = value.toLocal();
    String two(int part) => part.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}';
  }
}
