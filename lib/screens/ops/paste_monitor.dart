import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../theme.dart';
import '../../widgets/animations.dart';
import '../../widgets/responsive.dart';

class PasteMonitorScreen extends StatefulWidget {
  const PasteMonitorScreen({super.key});
  @override
  State<PasteMonitorScreen> createState() => _PasteMonitorScreenState();
}

class _PasteMonitorScreenState extends State<PasteMonitorScreen> {
  final ctrl = TextEditingController();
  List<dynamic> results = [];
  bool loading = false;
  String? error;

  Future<void> hunt() async {
    final q = ctrl.text.trim();
    if (q.isEmpty || loading) return;
    setState(() { loading = true; results = []; error = null; });

    try {
      final r = await http.get(
        Uri.parse('https://psbdump.app/api/search?q=${Uri.encodeQueryComponent(q)}'),
        headers: {'User-Agent': 'MazkiplayAI', 'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 20));

      if (r.statusCode < 200 || r.statusCode >= 300) {
        throw Exception('HTTP ${r.statusCode}');
      }
      final decoded = jsonDecode(r.body);
      final data = decoded is Map ? decoded['data'] : null;
      final items = data is List ? data.take(30).toList() : <dynamic>[];
      if (!mounted) return;
      setState(() => results = items);
    } catch (e) {
      if (!mounted) return;
      setState(() => error = 'Hunt gagal: ${e}');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() { ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: MzTheme.bg,
    appBar: AppBar(title: const Text('PASTE HUNTER',
      style: TextStyle(color: MzTheme.red, letterSpacing: 2))),
    body: PageFade(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: TextField(
              controller: ctrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'keyword: domain, username, project...',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                filled: true, fillColor: MzTheme.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              ),
              onSubmitted: (_) => hunt(),
            )),
            const SizedBox(width: 10),
            Pressable(
              onTap: loading ? () {} : hunt,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: MzTheme.red, borderRadius: BorderRadius.circular(12)),
                child: loading
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.search, color: Colors.white),
              ),
            ),
          ]),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('❌ __ERROR__', textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
          ),
        Expanded(
          child: results.isEmpty
            ? Center(child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.travel_explore, color: Colors.white12, size: 64),
                    const SizedBox(height: 12),
                    Text(
                      'Masukkan keyword untuk mencari sumber paste publik.\n'
                      'OSINT saja — jangan gunakan untuk mengumpulkan atau '
                      'menyebarkan kredensial/data pribadi yang bocor.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38,
                        fontSize: fz(context, 13)),
                    ),
                  ],
                ),
              ))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: results.length,
                itemBuilder: (_, i) {
                  final raw = results[i];
                  final p = raw is Map
                    ? Map<String, dynamic>.from(raw)
                    : <String, dynamic>{};
                  return PopIn(
                    delayMs: (i * 40).clamp(0, 400),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: MzTheme.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p['user']?.toString() ?? 'unknown',
                            style: const TextStyle(color: MzTheme.red,
                              fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(p['title']?.toString() ?? '', maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 6),
                          Text('${p['date'] ?? ''} • size ${p['size'] ?? '?'}',
                            style: const TextStyle(color: Colors.white38, fontSize: 10)),
                        ],
                      ),
                    ),
                  );
                },
              ),
        ),
      ]),
    ),
  );
}
