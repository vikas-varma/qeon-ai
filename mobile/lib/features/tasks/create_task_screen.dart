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
  bool saving = false;

  Future<void> _save() async {
    final instruction = titleController.text.trim();
    if (instruction.length < 2 || saving) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Describe the task in at least 2 characters.'),
        ),
      );
      return;
    }
    setState(() => saving = true);
    try {
      await ref
          .read(tasksProvider.notifier)
          .addTask(
            instruction: instruction,
            schedule: schedule,
            requiresApproval: needsApproval,
          );
      if (mounted) context.pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the task. Try again.')),
      );
    }
  }

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
              label: saving ? 'Saving…' : 'Save task',
              icon: Icons.check_rounded,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
