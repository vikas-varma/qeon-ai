import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/qeon_components.dart';
import '../../state/app_state.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final titleController = TextEditingController();
  String schedule = 'Every day';
  bool needsApproval = true;

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create task')),
      body: QeonPage(
        child: ListView(
          children: [
            const ScreenHeader(
              title: 'What should Qeon AI do?',
              subtitle:
                  'Describe the result, schedule and permissions clearly.',
            ),
            const SizedBox(height: 18),
            TextField(
              controller: titleController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'Example: Summarize important unread emails every morning.',
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: schedule,
              decoration: const InputDecoration(
                labelText: 'Schedule',
                prefixIcon: Icon(Icons.schedule_rounded),
              ),
              items: const ['Once', 'Every day', 'Every week', 'Custom']
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => schedule = value ?? schedule),
            ),
            const SizedBox(height: 14),
            QeonCard(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: needsApproval,
                onChanged: (value) => setState(() => needsApproval = value),
                title: const Text(
                  'Require approval',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text(
                  'Ask before sending messages or changing connected data.',
                ),
              ),
            ),
            const SizedBox(height: 22),
            GradientButton(
              label: 'Save task',
              icon: Icons.check_rounded,
              onPressed: () {
                ref
                    .read(tasksProvider.notifier)
                    .addQuickTask(
                      titleController.text.isEmpty
                          ? 'New Qeon AI task'
                          : titleController.text,
                    );
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
