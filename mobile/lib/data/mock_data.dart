import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'models.dart';

const mockAgents = <AgentModel>[
  AgentModel(
    id: 'email',
    name: 'Email Agent',
    description: 'Manage emails, drafts, and important messages.',
    icon: Icons.mail_rounded,
    color: Color(0xFF5B63FF),
    capabilities: [
      'Summarize inbox',
      'Draft replies',
      'Find messages',
      'Prepare follow-ups',
    ],
  ),
  AgentModel(
    id: 'calendar',
    name: 'Calendar Agent',
    description: 'Manage events, reminders, and schedules.',
    icon: Icons.calendar_month_rounded,
    color: Color(0xFF2BA9F5),
    capabilities: [
      'View calendar',
      'Suggest time slots',
      'Create reminders',
      'Plan focus blocks',
    ],
  ),
  AgentModel(
    id: 'finance',
    name: 'Finance Agent',
    description: 'Track expenses, budgets, and useful insights.',
    icon: Icons.trending_up_rounded,
    color: Color(0xFF18B98C),
    capabilities: [
      'Track expenses',
      'Budget planning',
      'Investment education',
      'Subscription tracking',
    ],
  ),
  AgentModel(
    id: 'travel',
    name: 'Travel Agent',
    description: 'Plan flights, hotels, visas, and itineraries.',
    icon: Icons.flight_takeoff_rounded,
    color: AppColors.primary,
    capabilities: [
      'Create itineraries',
      'Build checklists',
      'Compare options',
      'Calendar planning',
    ],
  ),
  AgentModel(
    id: 'research',
    name: 'Research Agent',
    description: 'Find and organize information with sources.',
    icon: Icons.search_rounded,
    color: Color(0xFF16A36D),
    capabilities: [
      'Deep research',
      'Summaries',
      'Source collection',
      'Structured reports',
    ],
  ),
  AgentModel(
    id: 'health',
    name: 'Health Agent',
    description: 'Support healthy routines and wellness goals.',
    icon: Icons.favorite_rounded,
    color: Color(0xFFF04455),
    capabilities: [
      'Habit tracking',
      'Routine planning',
      'Meal ideas',
      'Activity reminders',
    ],
  ),
];

const mockTasks = <TaskModel>[
  TaskModel(
    id: '1',
    title: 'Daily email summary',
    subtitle: 'Summarize unread priority messages.',
    schedule: 'Every day at 8:00 AM',
    icon: Icons.mail_rounded,
    color: Color(0xFFF5A623),
    status: TaskStatus.running,
  ),
  TaskModel(
    id: '2',
    title: 'Morning focus reminder',
    subtitle: 'Prepare today’s three important tasks.',
    schedule: 'Every day at 6:30 AM',
    icon: Icons.bolt_rounded,
    color: Color(0xFFF04B63),
    status: TaskStatus.running,
  ),
  TaskModel(
    id: '3',
    title: 'Weekly finance report',
    subtitle: 'Review spending and budget progress.',
    schedule: 'Every Sunday at 9:00 AM',
    icon: Icons.account_balance_wallet_rounded,
    color: Color(0xFF16A36D),
    status: TaskStatus.scheduled,
  ),
  TaskModel(
    id: '4',
    title: 'Book tickets to Goa',
    subtitle: 'Reminder to review travel options.',
    schedule: '28 May at 10:00 AM',
    icon: Icons.luggage_rounded,
    color: AppColors.primary,
    status: TaskStatus.scheduled,
  ),
  TaskModel(
    id: '5',
    title: 'AI news roundup',
    subtitle: 'Five important stories delivered.',
    schedule: 'Completed today at 7:02 AM',
    icon: Icons.newspaper_rounded,
    color: Color(0xFF2BA9F5),
    status: TaskStatus.completed,
  ),
];

const mockConversations = <ConversationModel>[
  ConversationModel(
    id: '1',
    title: 'Investment plan for 2026',
    preview: 'Build a balanced monthly plan...',
    time: 'Yesterday',
    icon: Icons.auto_graph_rounded,
    pinned: true,
  ),
  ConversationModel(
    id: '2',
    title: 'AI tools research',
    preview: 'Compare useful tools for my app...',
    time: '2 days ago',
    icon: Icons.search_rounded,
    pinned: true,
  ),
  ConversationModel(
    id: '3',
    title: 'Trip plan to Switzerland',
    preview: 'Create a seven-day itinerary...',
    time: '3 days ago',
    icon: Icons.flight_rounded,
  ),
  ConversationModel(
    id: '4',
    title: 'How AI will change the world',
    preview: 'Explain the major changes...',
    time: '4 days ago',
    icon: Icons.psychology_alt_rounded,
  ),
  ConversationModel(
    id: '5',
    title: 'Best books for productivity',
    preview: 'Recommend practical books...',
    time: '5 days ago',
    icon: Icons.menu_book_rounded,
  ),
  ConversationModel(
    id: '6',
    title: 'Email templates for work',
    preview: 'Create clear follow-up templates...',
    time: '6 days ago',
    icon: Icons.mail_outline_rounded,
  ),
];

const mockMemories = <MemoryModel>[
  MemoryModel(
    id: '1',
    category: 'Personal details',
    title: 'Preferred name',
    value: 'Vikas',
    icon: Icons.person_outline_rounded,
  ),
  MemoryModel(
    id: '2',
    category: 'Work information',
    title: 'Current focus',
    value: 'Building Qeon AI',
    icon: Icons.work_outline_rounded,
  ),
  MemoryModel(
    id: '3',
    category: 'Goals & routines',
    title: 'Main goal',
    value: 'Launch a useful AI product',
    icon: Icons.track_changes_rounded,
  ),
  MemoryModel(
    id: '4',
    category: 'Preferences',
    title: 'UI preference',
    value: 'Clean light theme with purple accents',
    icon: Icons.tune_rounded,
  ),
  MemoryModel(
    id: '5',
    category: 'Important people',
    title: 'Family',
    value: 'Keep family plans private',
    icon: Icons.people_outline_rounded,
  ),
];
