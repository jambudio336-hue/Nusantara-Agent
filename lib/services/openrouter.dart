import 'dart:convert';

import 'package:http/http.dart' as http;

class OpenRouterService {
  static final Uri _endpoint =
      Uri.parse('https://openrouter.ai/api/v1/chat/completions');

  Future<String> chat({
    required String apiKey,
    required String model,
    required List<Map<String, String>> messages,
  }) async {
    final key = apiKey.trim();
    final selectedModel = model.trim();

    if (key.isEmpty) {
      throw const OpenRouterException('OpenRouter API key belum diatur.');
    }
    if (selectedModel.isEmpty) {
      throw const OpenRouterException('Model OpenRouter belum diatur.');
    }

    final response = await http.post(
      _endpoint,
      headers: {
        'Authorization': 'Bearer ' + key,
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://github.com/jambudio336-hue/Nusantara-Agent',
        'X-Title': 'Mazkiplay AI',
      },
      body: jsonEncode({
        'model': selectedModel,
        'messages': messages,
      }),
    );

    Map<String, dynamic> data = {};
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw OpenRouterException(
        'Respons OpenRouter bukan JSON yang valid (' +
            response.statusCode.toString() +
            ').',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = data['error'];
      final message = error is Map
          ? error['message']?.toString()
          : error?.toString();
      throw OpenRouterException(
        message ?? 'OpenRouter HTTP ' + response.statusCode.toString() + '.',
      );
    }

    final choices = data['choices'];
    if (choices is! List || choices.isEmpty) {
      throw const OpenRouterException('OpenRouter tidak mengembalikan choices.');
    }

    final first = choices.first;
    final message = first is Map ? first['message'] : null;
    final content = message is Map ? message['content'] : null;

    if (content == null) {
      throw const OpenRouterException('Konten jawaban AI kosong.');
    }

    return content.toString();
  }
}

class OpenRouterException implements Exception {
  final String message;

  const OpenRouterException(this.message);

  @override
  String toString() => message;
}
