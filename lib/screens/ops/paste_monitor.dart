import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../theme.dart';
import '../../widgets/animations.dart';
import '../../widgets/responsive.dart';

class PasteMonitorScreen extends StatefulWidget {
  const PasteMonitorScreen({super.key});
  @override State<PasteMonitorScreen> createState() => _PasteMonitorScreenState();
}

class _PasteMonitorScreenState extends State<PasteMonitorScreen> {
  final controller = TextEditingController();
  List<dynamic> results = [];
  bool loading = false;
  String? error;

  Future<void> _hunt() async {
    final q = controller.text.trim();
    if (q.isEmpty || loading) return;
    setState(() { loading = true; results = []; error = null; });
    try {
      final uri = Uri.https('psbdump.app', '/api/search', {'q': q});
      final response = await http.get(uri, headers: {
        'User-Agent': 'MazkiplayAI', 'Accept': 'application/json'
      }).timeout(const Duration(seconds: 20));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ' + response.statusCode.toString());
      }
      final decoded = jsonDecode(response.body);
      final raw = decoded is Map ? decoded['data'] : null;
      final items = raw is List ? raw.take(30).toList() : <dynamic>[];
      if (mounted) setState(() => results = items);
    } catch (e) {
      if (mounted) setState(() => error = 'Hunt gagal: ' + e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override void dispose() { controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: MzTheme.bg,
    appBar: AppBar(title: const Text('PASTE HUNTER',
      style: TextStyle(color: MzTheme.red, letterSpacing: 2))),
    body: PageFade(child: Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: Row(children: [
        Expanded(child: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'keyword: domain, username, project...'),
          onSubmitted: (_) => _hunt(),
        )),
        const SizedBox(width: 10),
        Pressable(
          onTap: loading ? () {} : _hunt,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: MzTheme.red, borderRadius: BorderRadius.circular(12)),
            child: loading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.search),
          ),
        ),
      ])),
      if (error != null) Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
      ),
      Expanded(
        child: results.isEmpty
          ? Center(child: Text(
              'Masukkan keyword untuk mencari sumber paste publik.\nOSINT saja — jangan gunakan untuk mengumpulkan atau menyebarkan kredensial/data pribadi yang bocor.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: fz(context, 13))))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: results.length,
              itemBuilder: (_, i) {
                final raw = results[i];
                final item = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
                return PopIn(
                  delayMs: (i * 40).clamp(0, 400).toInt(),
                  child: Card(child: ListTile(
                    leading: const Icon(Icons.public),
                    title: Text(item['user']?.toString() ?? 'unknown'),
                    subtitle: Text(item['title']?.toString() ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: Text(item['size']?.toString() ?? '?'),
                  )),
                );
              },
            ),
      ),
    ])),
  );
}
