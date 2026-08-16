import 'dart:convert';

import 'package:dio/dio.dart';

import '../config/app_config.dart';

class ApiClient {
  ApiClient({Dio? dio})
    : dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConfig.apiBaseUrl,
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 45),
              headers: const {'Content-Type': 'application/json'},
            ),
          );

  final Dio dio;

  void setBearerToken(String? token) {
    if (token == null || token.isEmpty) {
      dio.options.headers.remove('Authorization');
    } else {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<Map<String, dynamic>> gmailStatus() async {
    final response = await dio.get<Map<String, dynamic>>(
      '/integrations/gmail/status',
    );
    return response.data ?? const {'connected': false};
  }

  Future<Uri> connectGmail() async {
    final response = await dio.post<Map<String, dynamic>>(
      '/integrations/gmail/connect',
    );
    final value = response.data?['authorization_url'] as String?;
    if (value == null) {
      throw StateError('The Gmail authorization URL was missing.');
    }
    return Uri.parse(value);
  }

  Future<void> disconnectGmail() async {
    await dio.delete<void>('/integrations/gmail');
  }

  Future<Map<String, dynamic>> summarizeGmail({
    String query = 'in:inbox is:unread',
    int limit = 10,
  }) async {
    final response = await dio.get<Map<String, dynamic>>(
      '/integrations/gmail/summary',
      queryParameters: {'query': query, 'limit': limit},
    );
    return response.data ?? const {};
  }

  Future<List<Map<String, dynamic>>> searchGmail(
    String query, {
    int limit = 10,
  }) async {
    final response = await dio.get<Map<String, dynamic>>(
      '/integrations/gmail/messages',
      queryParameters: {'query': query, 'limit': limit},
    );
    final messages = response.data?['messages'] as List<dynamic>? ?? const [];
    return messages.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  Future<Map<String, dynamic>> createGmailDraft({
    required String to,
    required String subject,
    required String body,
    String? cc,
    String? bcc,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/integrations/gmail/drafts',
      data: {
        'to': to,
        'subject': subject,
        'body': body,
        if (cc != null && cc.isNotEmpty) 'cc': cc,
        if (bcc != null && bcc.isNotEmpty) 'bcc': bcc,
      },
    );
    return response.data ?? const {};
  }

  Future<Map<String, dynamic>> sendApprovedGmailDraft(String approvalId) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/integrations/gmail/drafts/$approvalId/send',
      data: const {'approved': true},
    );
    return response.data ?? const {};
  }

  Stream<ChatStreamEvent> streamChat(String message) async* {
    final response = await dio.post<ResponseBody>(
      '/chat/stream',
      data: {'message': message},
      options: Options(responseType: ResponseType.stream),
    );
    final body = response.data;
    if (body == null) {
      throw StateError('The chat response was empty.');
    }

    await for (final line
        in body.stream
            .map<List<int>>((chunk) => chunk)
            .transform(utf8.decoder)
            .transform(const LineSplitter())) {
      if (!line.startsWith('data: ')) continue;
      final data = jsonDecode(line.substring(6)) as Map<String, dynamic>;
      yield ChatStreamEvent(
        type: data['type'] as String? ?? 'error',
        text: data['text'] as String? ?? data['message'] as String? ?? '',
      );
    }
  }
}

class ChatStreamEvent {
  const ChatStreamEvent({required this.type, required this.text});

  final String type;
  final String text;
}
