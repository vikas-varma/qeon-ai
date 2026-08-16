import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/qeon_components.dart';
import '../../state/app_state.dart';

class AgentDetailScreen extends ConsumerWidget {
  const AgentDetailScreen({super.key, required this.agentId});
  final String agentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agents = ref.watch(agentsProvider);
    final agent = agents.firstWhere(
      (item) => item.id == agentId,
      orElse: () => agents.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(agent.name),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz_rounded),
          ),
        ],
      ),
      body: QeonPage(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
        child: ListView(
          children: [
            QeonCard(
              child: Column(
                children: [
                  CircleIcon(icon: agent.icon, color: agent.color, size: 76),
                  const SizedBox(height: 14),
                  Text(
                    agent.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    agent.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.circle,
                        color: AppColors.success,
                        size: 9,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        agent.enabled ? 'Active' : 'Disabled',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const SectionTitle('Capabilities'),
            QeonCard(
              child: Column(
                children: [
                  for (final capability in agent.capabilities)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                      ),
                      title: Text(
                        capability,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GradientButton(
              label: agent.id == 'email'
                  ? 'Open Email Agent'
                  : 'Chat with ${agent.name}',
              icon: agent.id == 'email'
                  ? Icons.mark_email_read_outlined
                  : Icons.chat_bubble_rounded,
              onPressed: () =>
                  context.push(agent.id == 'email' ? '/email-agent' : '/chat'),
            ),
            const SizedBox(height: 18),
            const SectionTitle('Recent activity'),
            const QeonCard(
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleIcon(
                      icon: Icons.description_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text('Monthly report'),
                    subtitle: Text('Generated two days ago'),
                  ),
                  Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleIcon(
                      icon: Icons.lightbulb_outline_rounded,
                      color: AppColors.warning,
                    ),
                    title: Text('Suggested next steps'),
                    subtitle: Text('Based on your recent conversation'),
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
