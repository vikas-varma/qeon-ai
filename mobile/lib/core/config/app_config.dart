class AppConfig {
  const AppConfig._();

  static const bool useMockData = false;
  static const String apiBaseUrl = String.fromEnvironment(
    'QEON_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );
}
