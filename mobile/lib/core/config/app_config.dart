class AppConfig {
  const AppConfig._();

  static const bool useMockData = false;
  static const String apiBaseUrl = String.fromEnvironment(
    'QEON_API_BASE_URL',
    defaultValue: 'https://api.qeonai.com/api/v1',
  );
}
