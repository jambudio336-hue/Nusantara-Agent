import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage.dart';
import 'welcome.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController api;
  late final TextEditingController hibp;
  late final TextEditingController model;
  late final TextEditingController twelve;

  @override
  void initState() {
    super.initState();
    api = TextEditingController(text: Store.apiKey ?? '');
    hibp = TextEditingController(text: Store.hibpKey ?? '');
    model = TextEditingController(text: Store.model);
    twelve = TextEditingController(text: Store.s.get('twelveDataKey')?.toString() ?? '');
  }

  @override
  void dispose() {
    api.dispose();
    hibp.dispose();
    model.dispose();
    twelve.dispose();
    super.dispose();
  }

  void _save() {
    Store.apiKey = api.text.trim().isEmpty ? null : api.text.trim();
    Store.hibpKey = hibp.text.trim().isEmpty ? null : hibp.text.trim();
    Store.model = model.text.trim().isEmpty ? 'openai/gpt-4o-mini' : model.text.trim();
    Store.s.put('twelveDataKey', twelve.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengaturan disimpan.')));
    setState(() {});
  }

  Future<void> _nuke() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('NUKE ALL DATA'),
        content: const Text('Hapus API key, riwayat, jurnal, target, dan pengaturan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (ok != true) return;
    await Hive.box('store').clear();
    await Hive.box('journal').clear();
    await Hive.box('targets').clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(
          Store.hasKey ? 'OpenRouter siap digunakan.' : 'Masukkan API key OpenRouter untuk mengaktifkan chat.',
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 22),
        TextField(controller: api, obscureText: true,
          decoration: const InputDecoration(labelText: 'OpenRouter API Key', prefixIcon: Icon(Icons.key_outlined))),
        const SizedBox(height: 14),
        TextField(controller: hibp, obscureText: true,
          decoration: const InputDecoration(
            labelText: 'HIBP API Key',
            prefixIcon: Icon(Icons.shield_outlined),
            helperText: 'Dipakai untuk pemeriksaan breach email. Disimpan lokal di perangkat.',
          )),
        const SizedBox(height: 14),
        TextField(controller: twelve, obscureText: true,
          decoration: const InputDecoration(labelText: 'Twelve Data API Key', prefixIcon: Icon(Icons.show_chart), helperText: 'Dipakai untuk candle Forex/Crypto dan polling live.')),
        const SizedBox(height: 14),
        TextField(controller: model,
          decoration: const InputDecoration(labelText: 'Model', prefixIcon: Icon(Icons.psychology_outlined))),
        const SizedBox(height: 20),
        ElevatedButton.icon(onPressed: _save, icon: const Icon(Icons.save_outlined), label: const Text('Simpan')),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () { Store.apiKey = null; api.clear(); setState(() {}); },
          icon: const Icon(Icons.delete_outline), label: const Text('Hapus API Key')),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () { Store.clearHistory(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Riwayat chat dihapus.'))); },
          icon: const Icon(Icons.history_toggle_off), label: const Text('Hapus Riwayat Chat')),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: _nuke,
          icon: const Icon(Icons.warning_amber_rounded),
          label: const Text('NUKE ALL DATA'),
        ),
      ],
    );
  }
}
