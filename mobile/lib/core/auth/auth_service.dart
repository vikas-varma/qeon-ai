import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../config/app_config.dart';

class AuthService {
  const AuthService._({required this.configured, this.configurationError});

  factory AuthService.unconfigured() => const AuthService._(
    configured: false,
    configurationError: 'Firebase has not been initialized.',
  );

  final bool configured;
  final String? configurationError;

  static Future<AuthService> initialize() async {
    try {
      if (AppConfig.hasDartFirebaseOptions) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: AppConfig.firebaseApiKey,
            appId: AppConfig.firebaseAppId,
            messagingSenderId: AppConfig.firebaseMessagingSenderId,
            projectId: AppConfig.firebaseProjectId,
          ),
        );
      } else {
        await Firebase.initializeApp();
      }
      await GoogleSignIn.instance.initialize(
        serverClientId: AppConfig.googleWebClientId.isEmpty
            ? null
            : AppConfig.googleWebClientId,
      );
      return const AuthService._(configured: true);
    } catch (error) {
      return AuthService._(
        configured: false,
        configurationError: error.toString(),
      );
    }
  }

  User? get currentUser =>
      configured ? FirebaseAuth.instance.currentUser : null;

  Stream<User?> authStateChanges() {
    if (!configured) return Stream.value(null);
    return FirebaseAuth.instance.authStateChanges();
  }

  Future<UserCredential> signInWithGoogle() async {
    if (!configured) {
      throw StateError('Firebase Authentication is not configured.');
    }
    final googleUser = await GoogleSignIn.instance.authenticate();
    final googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );
    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<String?> idToken() async {
    return currentUser?.getIdToken();
  }

  Future<void> signOut() async {
    if (!configured) return;
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn.instance.signOut();
  }
}

final authServiceProvider = Provider<AuthService>(
  (_) => AuthService.unconfigured(),
);

final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(authServiceProvider).authStateChanges(),
);
