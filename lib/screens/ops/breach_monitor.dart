import 'package:flutter/material.dart';
import '../../services/intel_api.dart';
import '../../theme.dart';
import '../../widgets/responsive.dart';

class BreachMonitorScreen extends StatefulWidget {
  const BreachMonitorScreen({super.key});
  @override
  State<BreachMonitorScreen> createState() => _BreachMonitorScreenState();
}
class _BreachMonitorScreenState extends State<BreachMonitorScreen> {
  final _controller = TextEditingController();
  int? count;
  String? error;
  bool loading = false;
  Future<void> _check() async {
    final password = _controller.text;
    if (password.isEmpty) return;
    setState(() { loading = true; error = null; count = null; });
    try {
      final value = await IntelApi.passwordBreachCount(password);
      if (mounted) setState(() { count = value; loading = false; });
    } catch (e) {
      if (mounted) setState(() { error = e.toString(); loading = false; });
    }
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => MzScaffold(
    title: 'BREACH MONITOR',
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Password breach check memakai k-anonymity; password mentah tidak dikirim.', style: TextStyle(color: Colors.white54)),
      const SizedBox(height: 12),
      TextField(controller: _controller, obscureText: true, decoration: const InputDecoration(labelText: 'Password to check')),
      const SizedBox(height: 12),
      ElevatedButton.icon(onPressed: loading ? null : _check, icon: const Icon(Icons.shield_outlined), label: const Text('CHECK')),
      if (loading) const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(color: MzTheme.red))),
      if (count != null) Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(
        count == 0 ? 'Tidak ditemukan pada dataset breach.' : 'Terdeteksi $count kali pada dataset breach.',
        style: TextStyle(color: count == 0 ? Colors.greenAccent : Colors.redAccent),
      ))),
      if (error != null) Text(error!, style: const TextStyle(color: Colors.redAccent)),
    ]),
  );
}
