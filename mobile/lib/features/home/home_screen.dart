import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/auth/auth_service.dart';
import '../../core/widgets/cosmic_logo.dart';
import '../../core/widgets/qeon_components.dart';
import '../../state/app_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).asData?.value;
    final firstName = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!.trim().split(' ').first
        : 'there';
    final recent =
        ref
            .watch(conversationsProvider)
            .asData
            ?.value
            .take(3)
            .toList(growable: false) ??
        const [];
    final prompts = [
      ('Write', Icons.edit_rounded),
      ('Plan', Icons.event_note_rounded),
      ('Research', Icons.search_rounded),
      ('Create task', Icons.task_alt_rounded),
    ];

    return QeonPage(
      child: ListView(
        children: [
          Row(
            children: [
              const CosmicLogo(size: 40),
              const SizedBox(width: 8),
              const Text(
                'Qeon AI',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded),
              ),
              CircleAvatar(
                radius: 18,
                child: Text(firstName.substring(0, 1).toUpperCase()),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'Hello, $firstName 👋',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          const Text(
            'How can I help you today?',
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 18),
          QeonCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                TextField(
                  readOnly: true,
                  onTap: () => context.push('/chat'),
                  decoration: const InputDecoration(
                    hintText: 'Ask anything or give a command...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                  ),
                ),
                Row(
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.mic_none_rounded, size: 18),
                      label: const Text('Voice'),
                      onPressed: () => context.push('/voice'),
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      avatar: const Icon(Icons.attach_file_rounded, size: 18),
                      label: const Text('Attach'),
                      onPressed: () {},
                    ),
                    const Spacer(),
                    FloatingActionButton.small(
                      onPressed: () => context.push('/chat'),
                      child: const Icon(Icons.arrow_upward_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final item in prompts)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: item == prompts.last ? 0 : 8,
                    ),
                    child: QeonCard(
                      padding: const EdgeInsets.symmetric(
                        vertical: 13,
                        horizontal: 6,
                      ),
                      onTap: () => item.$1 == 'Create task'
                          ? context.push('/create-task')
                          : context.push('/chat'),
                      child: Column(
                        children: [
                          Icon(item.$2, color: AppColors.primary),
                          const SizedBox(height: 7),
                          Text(
                            item.$1,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          const SectionTitle('Today at a glance'),
          const Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.task_alt_rounded,
                  label: 'Tasks',
                  value: '6 due today',
                ),
              ),
              SizedBox(width: 9),
              Expanded(
                child: _StatCard(
                  icon: Icons.calendar_month_rounded,
                  label: 'Calendar',
                  value: '2 events',
                ),
              ),
              SizedBox(width: 9),
              Expanded(
                child: _StatCard(
                  icon: Icons.timer_outlined,
                  label: 'Focus time',
                  value: '2h 30m',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SectionTitle(
            'Recent conversations',
            action: 'View all',
            onAction: () => context.go('/history'),
          ),
          QeonCard(
            padding: EdgeInsets.zero,
            child: recent.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'Start a chat and your recent conversations will appear here.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : Column(
                    children: [
                      for (var index = 0; index < recent.length; index++) ...[
                        Builder(
                          builder: (context) {
                            final conversation = recent[index];
                            return ListTile(
                              onTap: () => context.push(
                                '/chat?conversationId=${Uri.encodeQueryComponent(conversation.id)}',
                              ),
                              leading: CircleIcon(
                                icon: conversation.icon,
                                color: AppColors.primary,
                                size: 38,
                              ),
                              title: Text(
                                conversation.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(conversation.time),
                              trailing: const Icon(Icons.chevron_right_rounded),
                            );
                          },
                        ),
                        if (index != recent.length - 1)
                          const Divider(height: 1),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return QeonCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 21),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
