import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/auth/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = await AuthService.initialize();
  runApp(
    ProviderScope(
      overrides: [authServiceProvider.overrideWithValue(authService)],
      child: const QeonApp(),
    ),
  );
}
