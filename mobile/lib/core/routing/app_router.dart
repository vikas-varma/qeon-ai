import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/account/account_screen.dart';
import '../../features/agents/agent_detail_screen.dart';
import '../../features/agents/agents_screen.dart';
import '../../features/auth/onboarding_screen.dart';
import '../../features/auth/sign_in_screen.dart';
import '../../features/chat/chat_screen.dart';
import '../../features/chat/voice_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/integrations/connected_apps_screen.dart';
import '../../features/integrations/email_agent_screen.dart';
import '../../features/memory/memory_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/settings/appearance_screen.dart';
import '../../features/settings/activity_screen.dart';
import '../../features/settings/notifications_screen.dart';
import '../../features/settings/privacy_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/tasks/tasks_screen.dart';
import '../../features/tasks/create_task_screen.dart';
import '../../shell/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/sign-in', builder: (_, _) => const SignInScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/agents', builder: (_, _) => const AgentsScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/tasks', builder: (_, _) => const TasksScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (_, _) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/chat',
        builder: (_, state) => ChatScreen(
          conversationId: state.uri.queryParameters['conversationId'],
        ),
      ),
      GoRoute(path: '/voice', builder: (_, _) => const VoiceScreen()),
      GoRoute(
        path: '/agent/:id',
        builder: (_, state) => AgentDetailScreen(
          agentId: state.pathParameters['id'] ?? 'research',
        ),
      ),
      GoRoute(
        path: '/create-task',
        builder: (_, _) => const CreateTaskScreen(),
      ),
      GoRoute(path: '/memory', builder: (_, _) => const MemoryScreen()),
      GoRoute(
        path: '/connected-apps',
        builder: (_, _) => const ConnectedAppsScreen(),
      ),
      GoRoute(
        path: '/email-agent',
        builder: (_, _) => const EmailAgentScreen(),
      ),
      GoRoute(path: '/appearance', builder: (_, _) => const AppearanceScreen()),
      GoRoute(
        path: '/notifications',
        builder: (_, _) => const NotificationsScreen(),
      ),
      GoRoute(path: '/privacy', builder: (_, _) => const PrivacyScreen()),
      GoRoute(path: '/activity', builder: (_, _) => const ActivityScreen()),
      GoRoute(path: '/account', builder: (_, _) => const AccountScreen()),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 54),
            const SizedBox(height: 12),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go home'),
            ),
          ],
        ),
      ),
    ),
  );
});
