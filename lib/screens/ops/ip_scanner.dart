import 'package:flutter/material.dart';
import '../../services/intel_api.dart';
import '../../theme.dart';
import '../../widgets/responsive.dart';

class IpScannerScreen extends StatefulWidget {
  const IpScannerScreen({super.key});
  @override
  State<IpScannerScreen> createState() => _IpScannerScreenState();
}
class _IpScannerScreenState extends State<IpScannerScreen> {
  final _controller = TextEditingController();
  Map<String, dynamic>? result;
  String? error;
  bool loading = false;
  Future<void> _scan() async {
    final ip = _controller.text.trim();
    if (ip.isEmpty) return;
    setState(() { loading = true; error = null; });
    try {
      final data = await IntelApi.ipInfo(ip);
      if (mounted) setState(() { result = data; loading = false; });
    } catch (e) {
      if (mounted) setState(() { error = e.toString(); loading = false; });
    }
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => MzScaffold(
    title: 'IP SCANNER',
    body: ListView(padding: const EdgeInsets.all(16), children: [
      TextField(controller: _controller, decoration: const InputDecoration(labelText: 'IP address', hintText: '8.8.8.8')),
      const SizedBox(height: 12),
      ElevatedButton.icon(onPressed: loading ? null : _scan, icon: const Icon(Icons.search), label: const Text('LOOKUP')),
      if (loading) const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(color: MzTheme.red))),
      if (error != null) Padding(padding: const EdgeInsets.only(top: 16), child: Text(error!, style: const TextStyle(color: Colors.redAccent))),
      if (result != null) ...result!.entries.map((e) => ListTile(title: Text(e.key), subtitle: Text('${e.value ?? '-'}'))),
    ]),
  );
}
