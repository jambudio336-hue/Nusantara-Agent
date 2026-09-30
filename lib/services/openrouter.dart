import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'storage.dart';

class OpenRouter {
  static const endpoint =
      'https://openrouter.ai/api/v1/chat/completions';

  static const String systemPrompt = '''
Kamu adalah "Mazkiplay AI" — asisten keamanan siber & analisis serbaguna.
Kepribadian: profesional, blak-blakan, efisien, bahasa santai tapi presisi.
Selalu akhiri jawaban dengan: by.mazkiplay.com
Kemampuan:
- Keamanan siber: white hat / grey hat / black hat methodology (edukasi & authorized pentest),
  bug bounty recon, analisis kode & kerentanan (SAST, code review, CVE lookup).
- Membuat script multi-bahasa (Python, Bash, JS, Go, PHP, C, dll).
- OSINT dari sumber publik, forensik digital, scanning keamanan.
- Rekomendasi tools open-source di GitHub.
- Analisis market & trading: teknikal + fundamental, multi-timeframe,
  entry/SL/TP, money management, data publik seperti ForexFactory.
Gaya output: detail, terstruktur, langkah demi langkah, mudah dipahami, jangan menggurui.
Untuk teknik ofensif, berikan konteks edukasi/authorized testing dan tetap jelaskan teknis lengkap.
''';

  /// messages: [{"role": ..., "content": String atau List (vision)}]
  static Future<String> chat(List<Map<String, dynamic>> messages) async {
    final key = Store.apiKey;
    if (key == null || key.isEmpty) {
      return '⚠ API key belum diisi. Buka **Settings** dan masukkan OpenRouter API key kamu dulu.\n\nby.mazkiplay.com';
    }

    try {
      final res = await http
          .post(
            Uri.parse(endpoint),
            headers: {
              'Authorization': 'Bearer ' + key,
              'Content-Type': 'application/json',
              'HTTP-Referer': 'https://mazkiplay.com',
              'X-Title': 'Mazkiplay AI',
            },
            body: jsonEncode({
              'model': Store.model,
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                ...messages,
              ],
            }),
          )
          .timeout(const Duration(minutes: 3));

      final data = jsonDecode(res.body) as Map<String, dynamic>;

      if (data['error'] != null) {
        final error = data['error'];
        final message = error is Map
            ? error['message']?.toString() ?? error.toString()
            : error.toString();
        return '❌ ' + message + '\n\nby.mazkiplay.com';
      }

      final choices = data['choices'];
      if (choices is! List || choices.isEmpty) {
        return '❌ OpenRouter tidak mengembalikan hasil.\n\nby.mazkiplay.com';
      }

      final first = choices.first;
      final message = first is Map ? first['message'] : null;
      final responseContent = message is Map ? message['content'] : null;

      if (responseContent == null) {
        return '❌ Konten jawaban AI kosong.\n\nby.mazkiplay.com';
      }

      return responseContent.toString() + '\n\nby.mazkiplay.com';
    } on SocketException {
      return '❌ Tidak ada koneksi internet. APK ini full online, cek jaringan kamu.\n\nby.mazkiplay.com';
    } on FormatException {
      return '❌ Respons server tidak valid.\n\nby.mazkiplay.com';
    } catch (e) {
      return '❌ Error: ' + e.toString() + '\n\nby.mazkiplay.com';
    }
  }

  static Future<List<Map<String, dynamic>>> githubSearch(String q) async {
    final res = await http.get(
      Uri.parse(
        'https://api.github.com/search/repositories?q=' +
            Uri.encodeComponent(q) +
            '&sort=stars&per_page=10',
      ),
      headers: {'User-Agent': 'MazkiplayAI'},
    );

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['items'] ?? const []);
  }
}
