import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class IntelApi {
  static const ua = {'User-Agent': 'MazkiplayAI', 'Accept': 'application/json'};

  static Future<List<dynamic>> kev() async {
    final r = await http.get(
      Uri.parse('https://raw.githubusercontent.com/cisagov/kev-app-data/main/kev.json'),
      headers: ua,
    );
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('CISA KEV HTTP ' + r.statusCode.toString());
    }
    final d = jsonDecode(r.body);
    return d is Map ? List<dynamic>.from(d['vulnerabilities'] ?? const []).take(50).toList() : [];
  }

  static Future<List<dynamic>> recentCves() async {
    final start = DateTime.now().subtract(const Duration(days: 7));
    final stamp = start.toUtc().toIso8601String();
    final uri = Uri.https('services.nvd.nist.gov', '/rest/json/cves/2.0', {
      'pubStartDate': stamp,
      'resultsPerPage': '30',
    });
    final r = await http.get(uri, headers: ua);
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('NVD HTTP ' + r.statusCode.toString());
    }
    final d = jsonDecode(r.body);
    return d is Map ? List<dynamic>.from(d['vulnerabilities'] ?? const []) : [];
  }

  static Future<Map<String, dynamic>> ipInfo(String ip) async {
    final uri = Uri.https('ipapi.co', '/' + Uri.encodeComponent(ip) + '/json/');
    final r = await http.get(uri, headers: ua);
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('IP intel HTTP ' + r.statusCode.toString());
    }
    return Map<String, dynamic>.from(jsonDecode(r.body) as Map);
  }

  static Future<Map<String, dynamic>> sslAudit(String host) async {
    final encoded = Uri.encodeQueryComponent(host.trim());
    var r = await http.get(Uri.parse(
      'https://api.ssllabs.com/api/v3/analyze?host=' + encoded + '&publish=off&all=done&startNew=on'
    ), headers: ua);
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('SSL Labs HTTP ' + r.statusCode.toString());
    }
    var d = Map<String, dynamic>.from(jsonDecode(r.body) as Map);
    for (var i = 0; i < 30 && d['status'] != 'READY' && d['status'] != 'ERROR'; i++) {
      await Future.delayed(const Duration(seconds: 5));
      r = await http.get(Uri.parse(
        'https://api.ssllabs.com/api/v3/analyze?host=' + encoded + '&all=done'
      ), headers: ua);
      if (r.statusCode < 200 || r.statusCode >= 300) {
        throw Exception('SSL Labs polling HTTP ' + r.statusCode.toString());
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
      Uri.parse('https://api.pwnedpasswords.com/range/' + prefix),
      headers: ua,
    );
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('Pwned Passwords HTTP ' + r.statusCode.toString());
    }
    for (final line in r.body.split(RegExp(r'\r?\n'))) {
      final parts = line.split(':');
      if (parts.length == 2 && parts[0].trim() == suffix) {
        return int.tryParse(parts[1].trim()) ?? 0;
      }
    }
    return 0;
  }

  static Future<List<dynamic>> emailBreaches(String email, String apiKey) async {
    final uri = Uri.https('haveibeenpwned.com', '/api/v3/breachedaccount/' + Uri.encodeComponent(email.trim()),
      {'truncateResponse': 'false'});
    final r = await http.get(uri, headers: {'User-Agent': 'MazkiplayAI', 'hibp-api-key': apiKey});
    if (r.statusCode == 404) return [];
    if (r.statusCode == 401) throw Exception('HIBP API key invalid');
    if (r.statusCode < 200 || r.statusCode >= 300) throw Exception('HIBP HTTP ' + r.statusCode.toString());
    final data = jsonDecode(r.body);
    return data is List ? data : [];
  }
}
