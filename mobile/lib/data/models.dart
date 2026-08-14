import 'package:flutter/material.dart';

class AgentModel {
  const AgentModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.enabled = true,
    this.capabilities = const [],
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool enabled;
  final List<String> capabilities;

  AgentModel copyWith({bool? enabled}) => AgentModel(
    id: id,
    name: name,
    description: description,
    icon: icon,
    color: color,
    enabled: enabled ?? this.enabled,
    capabilities: capabilities,
  );
}

class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.schedule,
    required this.icon,
    required this.color,
    required this.status,
    this.paused = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final String schedule;
  final IconData icon;
  final Color color;
  final TaskStatus status;
  final bool paused;

  TaskModel copyWith({bool? paused, TaskStatus? status}) => TaskModel(
    id: id,
    title: title,
    subtitle: subtitle,
    schedule: schedule,
    icon: icon,
    color: color,
    status: status ?? this.status,
    paused: paused ?? this.paused,
  );
}

enum TaskStatus { running, scheduled, completed }

class ConversationModel {
  const ConversationModel({
    required this.id,
    required this.title,
    required this.preview,
    required this.time,
    required this.icon,
    this.pinned = false,
  });

  final String id;
  final String title;
  final String preview;
  final String time;
  final IconData icon;
  final bool pinned;
}

class MemoryModel {
  const MemoryModel({
    required this.id,
    required this.category,
    required this.title,
    required this.value,
    required this.icon,
  });

  final String id;
  final String category;
  final String title;
  final String value;
  final IconData icon;
}

class ChatMessage {
  const ChatMessage({required this.text, required this.isUser});
  final String text;
  final bool isUser;
}
