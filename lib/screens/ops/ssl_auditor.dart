import 'package:flutter/material.dart';
import '../../services/intel_api.dart';
import '../../theme.dart';
import '../../widgets/responsive.dart';

class SslAuditorScreen extends StatefulWidget {
  const SslAuditorScreen({super.key});
  @override
  State<SslAuditorScreen> createState() => _SslAuditorScreenState();
}
class _SslAuditorScreenState extends State<SslAuditorScreen> {
  final _controller = TextEditingController();
  Map<String, dynamic>? result;
  String? error;
  bool loading = false;
  Future<void> _audit() async {
    final host = _controller.text.trim();
    if (host.isEmpty) return;
    setState(() { loading = true; error = null; });
    try {
      final data = await IntelApi.sslAudit(host);
      if (mounted) setState(() { result = data; loading = false; });
    } catch (e) {
      if (mounted) setState(() { error = e.toString(); loading = false; });
    }
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => MzScaffold(
    title: 'SSL AUDITOR',
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Gunakan hanya domain yang berwenang untuk diaudit.', style: TextStyle(color: Colors.white54)),
      const SizedBox(height: 12),
      TextField(controller: _controller, decoration: const InputDecoration(labelText: 'Hostname', hintText: 'example.com')),
      const SizedBox(height: 12),
      ElevatedButton.icon(onPressed: loading ? null : _audit, icon: const Icon(Icons.security), label: const Text('START AUDIT')),
      if (loading) const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(color: MzTheme.red))),
      if (error != null) Padding(padding: const EdgeInsets.only(top: 16), child: Text(error!, style: const TextStyle(color: Colors.redAccent))),
      if (result != null) Card(child: Padding(padding: const EdgeInsets.all(14), child: Text(
        'Status: ${result!['status'] ?? '-'}\n'
        'Grade: ${result!['endpoints'] is List && (result!['endpoints'] as List).isNotEmpty ? (result!['endpoints'] as List).first['grade'] ?? '-' : '-'}',
        style: const TextStyle(color: Colors.white70),
      ))),
    ]),
  );
}
