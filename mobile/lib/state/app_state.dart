import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/auth/auth_service.dart';
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

  Future<void> add({
    required String category,
    required String title,
    required String value,
  }) async {
    if (AppConfig.useMockData) return;
    final row = await ref
        .read(apiClientProvider)
        .createMemory(category: category, title: title, value: value);
    final current = state.asData?.value ?? const <MemoryModel>[];
    state = AsyncData([_memoryFromJson(row), ...current]);
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

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(tokenProvider: ref.watch(authServiceProvider).idToken),
);

class ConversationsController extends AsyncNotifier<List<ConversationModel>> {
  @override
  Future<List<ConversationModel>> build() async {
    if (AppConfig.useMockData) return List.of(mockConversations);
    final rows = await ref.read(apiClientProvider).listConversations();
    return rows.map(_conversationFromJson).toList(growable: false);
  }

  Future<void> delete(String id) async {
    if (!AppConfig.useMockData) {
      await ref.read(apiClientProvider).deleteConversation(id);
    }
    final current = state.asData?.value ?? const <ConversationModel>[];
    state = AsyncData(
      current.where((conversation) => conversation.id != id).toList(),
    );
  }

  ConversationModel _conversationFromJson(Map<String, dynamic> row) {
    final updatedAt = DateTime.tryParse(row['updated_at'] as String? ?? '');
    return ConversationModel(
      id: row['id'] as String? ?? '',
      title: row['title'] as String? ?? 'Conversation',
      preview: row['preview'] as String? ?? '',
      time: _relativeTime(updatedAt),
      icon: Icons.auto_awesome_rounded,
      pinned: row['pinned'] as bool? ?? false,
    );
  }

  String _relativeTime(DateTime? value) {
    if (value == null) return '';
    final difference = DateTime.now().difference(value.toLocal());
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes} min ago';
    if (difference.inDays < 1) return '${difference.inHours} hr ago';
    if (difference.inDays == 1) return 'Yesterday';
    return '${difference.inDays} days ago';
  }
}

final conversationsProvider =
    AsyncNotifierProvider<ConversationsController, List<ConversationModel>>(
      ConversationsController.new,
    );

class ChatController extends Notifier<List<ChatMessage>> {
  bool _sending = false;
  String? _conversationId;
  int _loadGeneration = 0;

  @override
  List<ChatMessage> build() => const [
    ChatMessage(
      text:
          'Hello. I’m ready to help you plan, research, write, and organize your work.',
      isUser: false,
    ),
  ];

  Future<void> openConversation(String? conversationId) async {
    final generation = ++_loadGeneration;
    _conversationId = conversationId;
    _sending = false;
    if (conversationId == null || AppConfig.useMockData) {
      state = build();
      return;
    }
    state = const [ChatMessage(text: 'Loading conversation…', isUser: false)];
    try {
      final row = await ref
          .read(apiClientProvider)
          .getConversation(conversationId);
      if (generation != _loadGeneration) return;
      final messages = row['messages'] as List<dynamic>? ?? const [];
      state = messages
          .whereType<Map<String, dynamic>>()
          .map((message) {
            return ChatMessage(
              text: message['content'] as String? ?? '',
              isUser: message['role'] == 'user',
            );
          })
          .toList(growable: false);
    } catch (_) {
      if (generation != _loadGeneration) return;
      state = const [
        ChatMessage(
          text: 'Could not load this conversation. Please try again.',
          isUser: false,
        ),
      ];
    }
  }

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
          in ref
              .read(apiClientProvider)
              .streamChat(message, conversationId: _conversationId)) {
        if (event.type == 'meta' && event.conversationId != null) {
          _conversationId = event.conversationId;
        }
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
      ref.invalidate(conversationsProvider);
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
