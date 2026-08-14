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

class TasksController extends Notifier<List<TaskModel>> {
  @override
  List<TaskModel> build() => List.of(mockTasks);

  void togglePause(String id) {
    state = [
      for (final task in state)
        if (task.id == id) task.copyWith(paused: !task.paused) else task,
    ];
  }

  void addQuickTask(String title) {
    state = [
      ...state,
      TaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        subtitle: 'Created from the Qeon AI starter interface.',
        schedule: 'Today',
        icon: Icons.auto_awesome_rounded,
        color: const Color(0xFF6D35F6),
        status: TaskStatus.scheduled,
      ),
    ];
  }

  void delete(String id) =>
      state = state.where((task) => task.id != id).toList();
}

final tasksProvider = NotifierProvider<TasksController, List<TaskModel>>(
  TasksController.new,
);

class MemoryController extends Notifier<List<MemoryModel>> {
  @override
  List<MemoryModel> build() => List.of(mockMemories);

  void delete(String id) =>
      state = state.where((memory) => memory.id != id).toList();
  void clear() => state = [];
}

final memoriesProvider = NotifierProvider<MemoryController, List<MemoryModel>>(
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
