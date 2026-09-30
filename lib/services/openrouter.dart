import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'storage.dart';

class OpenRouter {
  static const endpoint = 'https://openrouter.ai/api/v1/chat/completions';
  static const modelsEndpoint = 'https://openrouter.ai/api/v1/models';
  static const String systemPrompt = '''
Kamu adalah "Mazkiplay AI" — asisten keamanan siber & analisis serbaguna.
Kepribadian: profesional, blak-blakan, efisien, bahasa santai tapi presisi.
Selalu akhiri jawaban dengan: by.mazkiplay.com
Kemampuan: keamanan siber untuk edukasi/authorized testing, code review, OSINT sumber publik,
analisis CVE, scripting, tools open-source, market/trading analysis dan workflow produktivitas.
Gaya output: detail, terstruktur, langkah demi langkah, mudah dipahami, jangan menggurui.
Untuk teknik ofensif, kontekskan pada edukasi/authorized testing.
''';

  static Map<String, String> _headers(String key) => {
    'Authorization': 'Bearer ' + key,
    'Content-Type': 'application/json',
    'HTTP-Referer': 'https://mazkiplay.com',
    'X-Title': 'Mazkiplay AI',
  };

  static Future<String> chat(List<Map<String, dynamic>> messages) async {
    final key = Store.apiKey;
    if (key == null || key.isEmpty) return '⚠ API key belum diisi. Buka Settings dan masukkan OpenRouter API key kamu dulu.\n\nby.mazkiplay.com';
    try {
      final res = await http.post(Uri.parse(endpoint), headers: _headers(key), body: jsonEncode({
        'model': Store.model,
        'messages': [{'role': 'system', 'content': systemPrompt}, ...messages],
      })).timeout(const Duration(minutes: 3));
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['error'] != null) {
        final e = data['error'];
        final m = e is Map ? e['message']?.toString() ?? e.toString() : e.toString();
        return '❌ ' + m + '\n\nby.mazkiplay.com';
      }
      final choices = data['choices'];
      if (choices is! List || choices.isEmpty) return '❌ OpenRouter tidak mengembalikan hasil.\n\nby.mazkiplay.com';
      final message = choices.first is Map ? choices.first['message'] : null;
      final content = message is Map ? message['content'] : null;
      return content == null ? '❌ Konten jawaban AI kosong.\n\nby.mazkiplay.com' : content.toString() + '\n\nby.mazkiplay.com';
    } on SocketException {
      return '❌ Tidak ada koneksi internet. APK ini membutuhkan koneksi online.\n\nby.mazkiplay.com';
    } on FormatException {
      return '❌ Respons server tidak valid.\n\nby.mazkiplay.com';
    } catch (e) {
      return '❌ Error: ' + e.toString() + '\n\nby.mazkiplay.com';
    }
  }

  static Stream<String> chatStream(List<Map<String, dynamic>> messages) async* {
    final key = Store.apiKey;
    if (key == null || key.isEmpty) {
      yield '⚠ API key belum diisi. Buka Settings dan masukkan OpenRouter API key kamu dulu.\n\nby.mazkiplay.com';
      return;
    }
    final request = http.Request('POST', Uri.parse(endpoint));
    request.headers.addAll(_headers(key));
    request.body = jsonEncode({
      'model': Store.model,
      'stream': true,
      'messages': [{'role': 'system', 'content': systemPrompt}, ...messages],
    });
    try {
      final response = await request.send().timeout(const Duration(minutes: 3));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final body = await response.stream.bytesToString();
        yield '❌ OpenRouter HTTP ' + response.statusCode.toString() + ': ' + body;
        return;
      }
      final buffer = StringBuffer();
      await for (final chunk in response.stream.transform(utf8.decoder)) {
        buffer.write(chunk);
        final lines = buffer.toString().split('\n');
        buffer.clear();
        if (lines.isNotEmpty && !lines.last.trim().isEmpty) buffer.write(lines.last);
        for (var i = 0; i < lines.length - 1; i++) {
          final line = lines[i].trim();
          if (!line.startsWith('data:')) continue;
          final payload = line.substring(5).trim();
          if (payload == '[DONE]' || payload.isEmpty) continue;
          try {
            final data = jsonDecode(payload);
            final choices = data is Map ? data['choices'] : null;
            final delta = choices is List && choices.isNotEmpty ? choices.first['delta'] : null;
            final content = delta is Map ? delta['content'] : null;
            if (content != null) yield content.toString();
          } catch (_) {}
        }
      }
      yield '\n\nby.mazkiplay.com';
    } on SocketException {
      yield '❌ Koneksi ke OpenRouter terputus.';
    } catch (e) {
      yield '❌ Streaming error: ' + e.toString();
    }
  }

  static Future<List<Map<String, dynamic>>> models() async {
    final key = Store.apiKey;
    final headers = key == null || key.isEmpty ? {'Accept': 'application/json'} : _headers(key);
    final res = await http.get(Uri.parse(modelsEndpoint), headers: headers).timeout(const Duration(seconds: 30));
    if (res.statusCode < 200 || res.statusCode >= 300) throw Exception('OpenRouter models HTTP ' + res.statusCode.toString());
    final data = jsonDecode(res.body);
    final items = data is Map ? data['data'] : null;
    return items is List ? items.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList() : <Map<String, dynamic>>[];
  }

  static Future<List<Map<String, dynamic>>> githubSearch(String q) async {
    final res = await http.get(Uri.parse('https://api.github.com/search/repositories?q=' + Uri.encodeComponent(q) + '&sort=stars&per_page=10'), headers: {'User-Agent': 'MazkiplayAI'});
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['items'] ?? const []);
  }
}