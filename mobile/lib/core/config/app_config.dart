class AppConfig {
  const AppConfig._();

  static const bool useMockData = false;
  static const String apiBaseUrl = String.fromEnvironment(
    'QEON_API_BASE_URL',
    defaultValue: 'https://api.qeonai.com/api/v1',
  );

  static const String firebaseApiKey = String.fromEnvironment(
    'QEON_FIREBASE_API_KEY',
  );
  static const String firebaseAppId = String.fromEnvironment(
    'QEON_FIREBASE_APP_ID',
  );
  static const String firebaseMessagingSenderId = String.fromEnvironment(
    'QEON_FIREBASE_MESSAGING_SENDER_ID',
  );
  static const String firebaseProjectId = String.fromEnvironment(
    'QEON_FIREBASE_PROJECT_ID',
  );
  static const String googleWebClientId = String.fromEnvironment(
    'QEON_GOOGLE_WEB_CLIENT_ID',
  );

  static bool get hasDartFirebaseOptions =>
      firebaseApiKey.isNotEmpty &&
      firebaseAppId.isNotEmpty &&
      firebaseMessagingSenderId.isNotEmpty &&
      firebaseProjectId.isNotEmpty;
}
