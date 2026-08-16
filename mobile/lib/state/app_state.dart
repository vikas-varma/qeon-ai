import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../data/mock_data.dart';
import '../data/models.dart';

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  void setMode(ThemeMode mode) => state = mode;
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class AgentsController extends Notifier<List<AgentModel>> {
  @override
  List<AgentModel> build() => List.of(mockAgents);

  void toggle(String id) {
    state = [
      for (final agent in state)
        if (agent.id == id) agent.copyWith(enabled: !agent.enabled) else agent,
    ];
  }
}

final agentsProvider = NotifierProvider<AgentsController, List<AgentModel>>(
  AgentsController.new,
);

class TasksController extends AsyncNotifier<List<TaskModel>> {
  @override
  Future<List<TaskModel>> build() async {
    if (AppConfig.useMockData) return List.of(mockTasks);
    final rows = await ref.read(apiClientProvider).listTasks();
    return rows.map(_taskFromJson).toList(growable: false);
  }

  Future<void> addTask({
    required String instruction,
    required String schedule,
    required bool requiresApproval,
  }) async {
    final title = instruction.length > 80
        ? '${instruction.substring(0, 77)}...'
        : instruction;
    final current = state.asData?.value ?? const <TaskModel>[];
    if (AppConfig.useMockData) {
      state = AsyncData([
        ...current,
        TaskModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          subtitle: instruction,
          schedule: schedule,
          icon: Icons.auto_awesome_rounded,
          color: const Color(0xFF6D35F6),
          status: TaskStatus.scheduled,
        ),
      ]);
      return;
    }
    final row = await ref
        .read(apiClientProvider)
        .createTask(
          title: title,
          instruction: instruction,
          schedule: schedule,
          requiresApproval: requiresApproval,
        );
    state = AsyncData([_taskFromJson(row), ...current]);
  }

  Future<void> delete(String id) async {
    if (!AppConfig.useMockData) {
      await ref.read(apiClientProvider).deleteTask(id);
    }
    final current = state.asData?.value ?? const <TaskModel>[];
    state = AsyncData(current.where((task) => task.id != id).toList());
  }

  TaskModel _taskFromJson(Map<String, dynamic> row) {
    final statusName = row['status'] as String? ?? 'scheduled';
    final status = TaskStatus.values.firstWhere(
      (value) => value.name == statusName,
      orElse: () => TaskStatus.scheduled,
    );
    return TaskModel(
      id: row['id'] as String? ?? '',
      title: row['title'] as String? ?? 'Task',
      subtitle: row['instruction'] as String? ?? '',
      schedule: row['schedule'] as String? ?? 'once',
      icon: Icons.auto_awesome_rounded,
      color: const Color(0xFF6D35F6),
      status: status,
    );
  }
}

final tasksProvider = AsyncNotifierProvider<TasksController, List<TaskModel>>(
  TasksController.new,
);

class MemoryController extends AsyncNotifier<List<MemoryModel>> {
  @override
  Future<List<MemoryModel>> build() async {
    if (AppConfig.useMockData) return List.of(mockMemories);
    final rows = await ref.read(apiClientProvider).listMemories();
    return rows.map(_memoryFromJson).toList(growable: false);
  }

  Future<void> delete(String id) async {
    if (!AppConfig.useMockData) {
      await ref.read(apiClientProvider).deleteMemory(id);
    }
    final current = state.asData?.value ?? const <MemoryModel>[];
    state = AsyncData(current.where((memory) => memory.id != id).toList());
  }

  Future<void> clear() async {
    if (!AppConfig.useMockData) {
      await ref.read(apiClientProvider).clearMemories();
    }
    state = const AsyncData([]);
  }

  MemoryModel _memoryFromJson(Map<String, dynamic> row) => MemoryModel(
    id: row['id'] as String? ?? '',
    category: row['category'] as String? ?? 'General',
    title: row['title'] as String? ?? 'Memory',
    value: row['value'] as String? ?? '',
    icon: Icons.bookmark_outline_rounded,
  );
}

final memoriesProvider =
    AsyncNotifierProvider<MemoryController, List<MemoryModel>>(
      MemoryController.new,
    );

class MemoryEnabledController extends Notifier<bool> {
  @override
  bool build() => true;
  void toggle() => state = !state;
}

final memoryEnabledProvider = NotifierProvider<MemoryEnabledController, bool>(
  MemoryEnabledController.new,
);

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

class ChatController extends Notifier<List<ChatMessage>> {
  bool _sending = false;

  @override
  List<ChatMessage> build() => const [
    ChatMessage(
      text:
          'Hello Vikas. I’m ready to help you plan, research, write, and organize your work.',
      isUser: false,
    ),
  ];

  Future<void> send(String text) async {
    final message = text.trim();
    if (message.isEmpty || _sending) return;
    _sending = true;
    state = [
      ...state,
      ChatMessage(text: message, isUser: true),
      const ChatMessage(text: 'Thinking…', isUser: false),
    ];

    if (AppConfig.useMockData) {
      _replaceLast('Mock Qeon AI response to: $message');
      _sending = false;
      return;
    }

    var answer = '';
    try {
      await for (final event
          in ref.read(apiClientProvider).streamChat(message)) {
        if (event.type == 'delta') {
          answer += event.text;
          _replaceLast(answer);
        } else if (event.type == 'error') {
          _replaceLast(event.text);
        }
      }
      if (answer.isEmpty && state.last.text == 'Thinking…') {
        _replaceLast('No response was received. Please try again.');
      }
    } catch (_) {
      _replaceLast(
        'Could not reach the Qeon AI backend. Make sure the backend is running and try again.',
      );
    } finally {
      _sending = false;
    }
  }

  void _replaceLast(String text) {
    state = [
      ...state.take(state.length - 1),
      ChatMessage(text: text, isUser: false),
    ];
  }
}

final chatProvider = NotifierProvider<ChatController, List<ChatMessage>>(
  ChatController.new,
);
