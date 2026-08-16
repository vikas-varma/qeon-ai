import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/qeon_components.dart';
import '../../data/models.dart';
import '../../state/app_state.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String query = '';
  bool pinnedOnly = false;

  @override
  Widget build(BuildContext context) {
    final conversations = ref.watch(conversationsProvider);
    return QeonPage(
      child: Column(
        children: [
          ScreenHeader(
            title: 'History',
            subtitle: 'Your saved conversations.',
            trailing: IconButton(
              tooltip: 'New conversation',
              onPressed: () => context.push('/chat'),
              icon: const Icon(Icons.add_comment_rounded),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            onChanged: (value) => setState(() => query = value.trim()),
            decoration: const InputDecoration(
              hintText: 'Search conversations...',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: !pinnedOnly,
                onSelected: (_) => setState(() => pinnedOnly = false),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Pinned'),
                selected: pinnedOnly,
                onSelected: (_) => setState(() => pinnedOnly = true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: conversations.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => _HistoryError(
                onRetry: () => ref.invalidate(conversationsProvider),
              ),
              data: (items) {
                final filtered = _filter(items);
                if (filtered.isEmpty) {
                  return _EmptyHistory(
                    hasFilter: query.isNotEmpty || pinnedOnly,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(conversationsProvider);
                    await ref.read(conversationsProvider.future);
                  },
                  child: QeonCard(
                    padding: EdgeInsets.zero,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return _ConversationTile(
                          conversation: item,
                          onOpen: () => context.push(
                            '/chat?conversationId=${Uri.encodeQueryComponent(item.id)}',
                          ),
                          onDelete: () => _delete(item),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<ConversationModel> _filter(List<ConversationModel> items) {
    final normalized = query.toLowerCase();
    return items
        .where((item) {
          if (pinnedOnly && !item.pinned) return false;
          if (normalized.isEmpty) return true;
          return item.title.toLowerCase().contains(normalized) ||
              item.preview.toLowerCase().contains(normalized);
        })
        .toList(growable: false);
  }

  Future<void> _delete(ConversationModel conversation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete conversation?'),
        content: Text('“${conversation.title}” will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(conversationsProvider.notifier).delete(conversation.id);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete the conversation.')),
      );
    }
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.onOpen,
    required this.onDelete,
  });

  final ConversationModel conversation;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onOpen,
      contentPadding: const EdgeInsets.only(left: 14, top: 7, bottom: 7),
      leading: CircleIcon(
        icon: conversation.icon,
        color: AppColors.primary,
        size: 42,
      ),
      title: Text(
        conversation.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        conversation.preview.isEmpty
            ? conversation.time
            : '${conversation.preview}\n${conversation.time}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'delete') onDelete();
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
        icon: const Icon(Icons.more_vert_rounded),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.hasFilter});

  final bool hasFilter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        hasFilter
            ? 'No conversations match this filter.'
            : 'Your conversations will appear here after you chat.',
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textMuted),
      ),
    );
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Could not load conversation history.'),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}
