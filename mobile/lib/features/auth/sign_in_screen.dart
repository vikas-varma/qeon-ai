import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/cosmic_logo.dart';
import '../../core/widgets/qeon_components.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  bool signingIn = false;

  Future<void> _signInWithGoogle() async {
    if (signingIn) return;
    setState(() => signingIn = true);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      if (mounted) context.go('/home');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google sign-in did not complete. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => signingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    return Scaffold(
      body: QeonPage(
        child: ListView(
          children: [
            const SizedBox(height: 54),
            const Center(child: CosmicLogo(size: 92)),
            const SizedBox(height: 24),
            Text(
              'Welcome to Qeon AI',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 9),
            const Text(
              'Sign in securely to keep your conversations, tasks, memory, and connected apps private to your account.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, height: 1.45),
            ),
            const SizedBox(height: 38),
            OutlinedButton.icon(
              key: const Key('google-sign-in-button'),
              onPressed: authService.configured && !signingIn
                  ? _signInWithGoogle
                  : null,
              icon: signingIn
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.g_mobiledata_rounded, size: 30),
              label: Text(signingIn ? 'Signing in…' : 'Continue with Google'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const QeonCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.primary),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Signing in identifies your Qeon AI account. Gmail access is separate and is requested only if you later choose Connect Gmail.',
                      style: TextStyle(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            if (!authService.configured) ...[
              const SizedBox(height: 18),
              const Text(
                'Firebase setup is incomplete. Add the Android Firebase configuration before testing sign-in.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.danger, fontSize: 12),
              ),
            ],
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => context.push('/privacy'),
              child: const Text('Privacy & data controls'),
            ),
          ],
        ),
      ),
    );
  }
}
