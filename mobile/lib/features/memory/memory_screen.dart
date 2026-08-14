import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/qeon_components.dart';
import '../../state/app_state.dart';

class MemoryScreen extends ConsumerWidget {
  const MemoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(memoryEnabledProvider);
    final memories = ref.watch(memoriesProvider);
    final groups = <String, int>{};
    for (final memory in memories) {
      groups[memory.category] = (groups[memory.category] ?? 0) + 1;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Memory & Personalization')),
      body: QeonPage(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
        child: ListView(
          children: [
            QeonCard(
              child: SwitchListTile(
                value: enabled,
                onChanged: (_) =>
                    ref.read(memoryEnabledProvider.notifier).toggle(),
                contentPadding: EdgeInsets.zero,
                secondary: const CircleIcon(
                  icon: Icons.psychology_alt_rounded,
                  color: AppColors.primary,
                ),
                title: const Text(
                  'Memory',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text(
                  'Qeon AI remembers useful details to personalize responses.',
                ),
              ),
            ),
            const SizedBox(height: 18),
            const SectionTitle('What Qeon AI remembers'),
            QeonCard(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              child: Column(
                children: [
                  if (groups.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No saved memories.'),
                    ),
                  for (final entry in groups.entries) ...[
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 2),
                      leading: const CircleIcon(
                        icon: Icons.folder_open_rounded,
                        color: AppColors.primary,
                        size: 40,
                      ),
                      title: Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      trailing: Text(
                        '${entry.value} items  ›',
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                    if (entry.key != groups.keys.last) const Divider(height: 1),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            const SectionTitle('Saved items'),
            for (final memory in memories) ...[
              QeonCard(
                padding: const EdgeInsets.all(10),
                child: ListTile(
                  leading: CircleIcon(
                    icon: memory.icon,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    memory.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(memory.value),
                  trailing: IconButton(
                    onPressed: () =>
                        ref.read(memoriesProvider.notifier).delete(memory.id),
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 9),
            ],
            OutlinedButton.icon(
              onPressed: memories.isEmpty
                  ? null
                  : () => _confirmClear(context, ref),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Clear all memory'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear all memory?'),
        content: const Text(
          'This removes every saved memory in this demo. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (accepted == true) ref.read(memoriesProvider.notifier).clear();
  }
}
