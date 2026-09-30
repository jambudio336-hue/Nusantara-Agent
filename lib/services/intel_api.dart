import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class IntelApi {
  static const ua = {
    'User-Agent': 'MazkiplayAI',
    'Accept': 'application/json',
  };

  static Future<List<dynamic>> kev() async {
    final r = await http.get(
      Uri.parse(
        'https://raw.githubusercontent.com/cisagov/kev-app-data/main/kev.json',
      ),
      headers: ua,
    );
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('CISA KEV HTTP \${r.statusCode}');
    }
    final d = jsonDecode(r.body) as Map<String, dynamic>;
    return List<dynamic>.from(d['vulnerabilities'] ?? const [])
        .take(50)
        .toList();
  }

  static Future<List<dynamic>> recentCves() async {
    final r = await http.get(
      Uri.parse(
        'https://services.nvd.nist.gov/rest/json/cves/2.0'
        '?pubStartDate=\${_daysAgo(7)}&resultsPerPage=30',
      ),
      headers: ua,
    );
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('NVD HTTP \${r.statusCode}');
    }
    final d = jsonDecode(r.body) as Map<String, dynamic>;
    return List<dynamic>.from(d['vulnerabilities'] ?? const []);
  }

  static String _daysAgo(int n) {
    final d = DateTime.now().subtract(Duration(days: n));
    return '\${d.year}-'
        '\${d.month.toString().padLeft(2, '0')}-'
        '\${d.day.toString().padLeft(2, '0')}T00:00:00.000';
  }

  static Future<Map<String, dynamic>> ipInfo(String ip) async {
    final r = await http.get(
      Uri.parse(
        'http://ip-api.com/json/\${Uri.encodeComponent(ip)}?fields=66846719',
      ),
      headers: ua,
    );
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('IP intel HTTP \${r.statusCode}');
    }
    return Map<String, dynamic>.from(jsonDecode(r.body) as Map);
  }

  static Future<Map<String, dynamic>> sslAudit(String host) async {
    final encodedHost = Uri.encodeComponent(host.trim());
    var r = await http.get(
      Uri.parse(
        'https://api.ssllabs.com/api/v3/analyze'
        '?host=\$encodedHost&publish=off&all=done&startNew=on',
      ),
      headers: ua,
    );
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('SSL Labs HTTP \${r.statusCode}');
    }

    var d = Map<String, dynamic>.from(jsonDecode(r.body) as Map);

    for (var i = 0; i < 30; i++) {
      if (d['status'] == 'READY' || d['status'] == 'ERROR') break;

      await Future.delayed(const Duration(seconds: 5));

      r = await http.get(
        Uri.parse(
          'https://api.ssllabs.com/api/v3/analyze'
          '?host=\$encodedHost&all=done',
        ),
        headers: ua,
      );
      if (r.statusCode < 200 || r.statusCode >= 300) {
        throw Exception('SSL Labs polling HTTP \${r.statusCode}');
      }
      d = Map<String, dynamic>.from(jsonDecode(r.body) as Map);
    }

    return d;
  }

  static Future<int> passwordBreachCount(String password) async {
    final hash = sha1.convert(utf8.encode(password)).toString().toUpperCase();
    final prefix = hash.substring(0, 5);
    final suffix = hash.substring(5);

    final r = await http.get(
      Uri.parse('https://api.pwnedpasswords.com/range/\$prefix'),
      headers: ua,
    );
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('Pwned Passwords HTTP \${r.statusCode}');
    }

    for (final line in r.body.split(RegExp(r'\r?\n'))) {
      final parts = line.split(':');
      if (parts.length == 2 && parts[0].trim() == suffix) {
        return int.tryParse(parts[1].trim()) ?? 0;
      }
    }
    return 0;
  }

  static Future<List<dynamic>> emailBreaches(
    String email,
    String apiKey,
  ) async {
    final encodedEmail = Uri.encodeComponent(email.trim());
    final r = await http.get(
      Uri.parse(
        'https://haveibeenpwned.com/api/v3/breachedaccount/'
        '\$encodedEmail?truncateResponse=false',
      ),
      headers: {
        'User-Agent': 'MazkiplayAI',
        'hibp-api-key': apiKey,
      },
    );

    if (r.statusCode == 404) return [];
    if (r.statusCode == 401) {
      throw Exception('HIBP API key invalid (isi di Settings)');
    }
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('HIBP HTTP \${r.statusCode}');
    }

    final data = jsonDecode(r.body);
    return data is List ? data : const [];
  }
}
