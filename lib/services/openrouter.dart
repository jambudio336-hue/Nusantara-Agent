import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'storage.dart';

class OpenRouter {
  static const endpoint = 'https://openrouter.ai/api/v1/chat/completions';
  static const modelsEndpoint = 'https://openrouter.ai/api/v1/models';
  static const systemPrompt = '''
Kamu adalah Mazkiplay AI, asisten berbahasa Indonesia yang ramah, terstruktur, dan profesional.
Bantu coding lintas bahasa, debugging, arsitektur aplikasi, analisis attachment, analisis data, trading research,
OSINT publik, dokumentasi, dan keamanan siber defensif/authorized testing.
Jangan membantu pencurian kredensial, malware, ransomware, eksploitasi target tanpa izin, senjata, narkotika,
atau pengintaian orang. Untuk permintaan berisiko, arahkan ke lab/CTF, mitigasi, threat modeling, atau responsible disclosure.
Jangan mengarang data live; jelaskan sumber dan batasan bila data tidak tersedia. Trading hanyalah informasi, bukan nasihat finansial.
Jika pengguna meminta analisis market, pisahkan data yang benar-benar tersedia dari asumsi, sertakan risiko dan skenario.
Jika pengguna mengunggah gambar/file, jelaskan apakah model yang dipilih mendukung modality tersebut.
Jawab dengan langkah yang jelas dan praktis. Selalu akhiri dengan: by.mazkiplay.com
''';

  static Map<String, String> _headers(String key) => {
    'Authorization': 'Bearer $key',
    'Content-Type': 'application/json',
    'HTTP-Referer': 'https://mazkiplay.com',
    'X-OpenRouter-Title': 'Mazkiplay AI',
  };

  static Future<List<Map<String, dynamic>>> models() async {
    final key = Store.apiKey;
    final headers = key == null || key.isEmpty ? {'Accept': 'application/json'} : _headers(key);
    final res = await http.get(Uri.parse(modelsEndpoint), headers: headers).timeout(const Duration(seconds: 30));
    final data = jsonDecode(res.body);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final detail = data is Map && data['error'] is Map ? data['error']['message'] : data;
      throw Exception('OpenRouter HTTP ${res.statusCode}: ${detail ?? 'respons tidak valid'}');
    }
    final items = data is Map ? data['data'] : null;
    return items is List ? items.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList() : <Map<String, dynamic>>[];
  }

  static Future<List<String>> _candidateModels() async {
    if (!Store.autoModel && Store.model.trim().isNotEmpty) return [Store.model.trim()];
    try {
      final discovered = await models();
      final free = discovered
          .map((m) => m['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty && id.contains(':free'))
          .take(5)
          .toList();
      return ['openrouter/auto', ...free, 'openai/gpt-4o-mini'];
    } catch (_) {
      return ['openrouter/auto', 'openai/gpt-4o-mini'];
    }
  }

  static Map<String, dynamic> _body(List<Map<String, dynamic>> messages, String model, {bool stream = false}) => {
    'model': model,
    'stream': stream,
    'temperature': 0.4,
    'messages': [{'role': 'system', 'content': systemPrompt}, ...messages],
  };

  static Future<String> chat(List<Map<String, dynamic>> messages) async {
    final key = Store.apiKey;
    if (key == null || key.isEmpty) return '⚠ API key belum diisi. Buka Settings lalu masukkan API key OpenRouter kamu.\n\nby.mazkiplay.com';
    Object? lastError;
    for (final model in await _candidateModels()) {
      try {
        final res = await http.post(Uri.parse(endpoint), headers: _headers(key), body: jsonEncode(_body(messages, model))).timeout(const Duration(minutes: 3));
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (res.statusCode < 200 || res.statusCode >= 300 || data['error'] != null) {
          lastError = data['error'] ?? 'HTTP ${res.statusCode}';
          continue;
        }
        final choices = data['choices'];
        final message = choices is List && choices.isNotEmpty ? choices.first['message'] : null;
        final content = message is Map ? message['content'] : null;
        if (content != null) return '${content.toString()}\n\nby.mazkiplay.com';
      } catch (e) { lastError = e; }
    }
    return '❌ Semua model OpenRouter gagal: ${lastError ?? 'respons kosong'}\n\nby.mazkiplay.com';
  }

  static Stream<String> chatStream(List<Map<String, dynamic>> messages) async* {
    final key = Store.apiKey;
    if (key == null || key.isEmpty) {
      yield '⚠ API key belum diisi. Buka Settings lalu masukkan API key OpenRouter kamu.\n\nby.mazkiplay.com';
      return;
    }
    Object? lastError;
    for (final model in await _candidateModels()) {
      final request = http.Request('POST', Uri.parse(endpoint));
      request.headers.addAll(_headers(key));
      request.body = jsonEncode(_body(messages, model, stream: true));
      try {
        final response = await request.send().timeout(const Duration(minutes: 3));
        if (response.statusCode < 200 || response.statusCode >= 300) {
          lastError = 'HTTP ${response.statusCode}: ${await response.stream.bytesToString()}';
          continue;
        }
        final buffer = StringBuffer();
        await for (final chunk in response.stream.transform(utf8.decoder)) {
          buffer.write(chunk);
          final lines = buffer.toString().split('\n');
          buffer.clear();
          if (lines.isNotEmpty && lines.last.trim().isNotEmpty) buffer.write(lines.last);
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
        return;
      } on SocketException catch (e) { lastError = e; }
      catch (e) { lastError = e; }
    }
    yield '❌ Semua model OpenRouter gagal: ${lastError ?? 'koneksi tidak tersedia'}\n\nby.mazkiplay.com';
  }

  static Future<List<Map<String, dynamic>>> githubSearch(String q) async {
    final res = await http.get(Uri.parse('https://api.github.com/search/repositories?q=${Uri.encodeComponent(q)}&sort=stars&per_page=10'), headers: {'User-Agent': 'MazkiplayAI'});
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['items'] ?? const []);
  }
}
