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
  TaskStatus selected = TaskStatus.running;

  @override
  Widget build(BuildContext context) {
    final allTasks = ref.watch(tasksProvider);
    final tasks = allTasks.where((task) => task.status == selected).toList();

    return QeonPage(
      child: Column(
        children: [
          ScreenHeader(
            title: 'Tasks',
            subtitle: 'Track what Qeon AI is doing.',
            trailing: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.filter_alt_outlined),
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
            child: tasks.isEmpty
                ? const Center(child: Text('No tasks in this section.'))
                : ListView.separated(
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
                              onSelected: (value) {
                                if (value == 'pause') {
                                  ref
                                      .read(tasksProvider.notifier)
                                      .togglePause(task.id);
                                }
                                if (value == 'delete') {
                                  ref
                                      .read(tasksProvider.notifier)
                                      .delete(task.id);
                                }
                              },
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                  value: 'pause',
                                  child: Text(task.paused ? 'Resume' : 'Pause'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ],
                        ),
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
