import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/qeon_components.dart';
import '../../data/models.dart';
import '../../state/app_state.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  TaskStatus selected = TaskStatus.scheduled;

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksProvider);

    return QeonPage(
      child: Column(
        children: [
          ScreenHeader(
            title: 'Tasks',
            subtitle: 'Track what Qeon AI is doing.',
            trailing: IconButton(
              onPressed: () => ref.invalidate(tasksProvider),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ),
          const SizedBox(height: 14),
          SegmentedButton<TaskStatus>(
            segments: const [
              ButtonSegment(value: TaskStatus.running, label: Text('Running')),
              ButtonSegment(
                value: TaskStatus.scheduled,
                label: Text('Scheduled'),
              ),
              ButtonSegment(
                value: TaskStatus.completed,
                label: Text('Completed'),
              ),
            ],
            selected: {selected},
            onSelectionChanged: (value) =>
                setState(() => selected = value.first),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: tasksState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => _LoadError(
                message: 'Could not load tasks.',
                onRetry: () => ref.invalidate(tasksProvider),
              ),
              data: (allTasks) {
                final tasks = allTasks
                    .where((task) => task.status == selected)
                    .toList();
                if (tasks.isEmpty) {
                  return const Center(child: Text('No tasks in this section.'));
                }
                return ListView.separated(
                  itemCount: tasks.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return QeonCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleIcon(icon: task.icon, color: task.color),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  task.subtitle,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  task.schedule,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value != 'delete') return;
                              try {
                                await ref
                                    .read(tasksProvider.notifier)
                                    .delete(task.id);
                              } catch (_) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Could not delete the task.'),
                                  ),
                                );
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          GradientButton(
            label: 'Create new task',
            icon: Icons.add_rounded,
            onPressed: () => context.push('/create-task'),
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
