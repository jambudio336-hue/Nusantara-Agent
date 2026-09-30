import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/openrouter.dart';
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
  bool autoModel = true;
  bool obscure = true;
  bool? connectionOk;
  List<String> discovered = [];
  bool loadingModels = false;

  @override
  void initState() {
    super.initState();
    api = TextEditingController(text: Store.apiKey ?? '');
    hibp = TextEditingController(text: Store.hibpKey ?? '');
    model = TextEditingController(text: Store.model);
    autoModel = Store.autoModel;
  }
  @override
  void dispose() { api.dispose(); hibp.dispose(); model.dispose(); super.dispose(); }

  Future<void> _save() async {
    await Store.saveApiKey(api.text.trim().isEmpty ? null : api.text.trim());
    Store.hibpKey = hibp.text.trim().isEmpty ? null : hibp.text.trim();
    Store.model = model.text.trim().isEmpty ? 'openrouter/auto' : model.text.trim();
    Store.autoModel = autoModel;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengaturan disimpan lokal di perangkat.')));
    setState(() {});
  }

  Future<void> _testKey() async {
    final key = api.text.trim();
    if (key.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan API key OpenRouter dulu.'))); return; }
    await Store.saveApiKey(key);
    setState(() => connectionOk = null);
    try {
      final models = await OpenRouter.models();
      if (mounted) { setState(() => connectionOk = true); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('API key valid. ${models.length} model tersedia.'))); }
    } catch (e) {
      if (mounted) { setState(() => connectionOk = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tes API key gagal: $e'), duration: const Duration(seconds: 6))); }
    }
  }

  Future<void> _discover() async {
    setState(() => loadingModels = true);
    try {
      final values = await OpenRouter.models();
      if (!mounted) return;
      setState(() => discovered = values.map((e) => e['id']?.toString() ?? '').where((e) => e.isNotEmpty).take(60).toList());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${discovered.length} model ditemukan.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Discovery gagal: $e')));
    } finally { if (mounted) setState(() => loadingModels = false); }
  }

  Future<void> _nuke() async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Hapus semua data lokal?'),
      content: const Text('API key, riwayat, jurnal, target, dan pengaturan akan dihapus dari perangkat.'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')), ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus'))],
    ));
    if (ok != true) return;
    await Hive.box('store').clear(); await Hive.box('journal').clear(); await Hive.box('targets').clear();
    Store.apiKey = null; Store.hibpKey = null;
    final prefs = await SharedPreferences.getInstance(); await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const WelcomeScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
    const SizedBox(height: 8),
    Row(children: [Icon(Icons.circle, size: 11, color: connectionOk == true ? Colors.greenAccent : connectionOk == false ? Colors.redAccent : Colors.orangeAccent), const SizedBox(width: 8), Text(connectionOk == true ? 'CONNECTED — OpenRouter merespons' : connectionOk == false ? 'CONNECTION FAILED — cek key dan limit' : 'NOT TESTED — tekan Tes API', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700))]),
    const SizedBox(height: 8),
    Text(Store.hasKey ? 'Key tersimpan lokal; status di atas berasal dari tes endpoint terakhir.' : 'Masukkan API key OpenRouter untuk mengaktifkan chat.', style: const TextStyle(color: Colors.white70)),
    const SizedBox(height: 18),
    TextField(controller: api, obscureText: obscure, decoration: InputDecoration(labelText: 'OpenRouter API Key', prefixIcon: const Icon(Icons.key_outlined), suffixIcon: IconButton(onPressed: () => setState(() => obscure = !obscure), icon: Icon(obscure ? Icons.visibility : Icons.visibility_off)))),
    const SizedBox(height: 8),
    const Text('Key tidak dibundel ke APK dan disimpan melalui secure storage platform.', style: TextStyle(color: Colors.white38, fontSize: 11)),
    const SizedBox(height: 14),
    SwitchListTile(contentPadding: EdgeInsets.zero, value: autoModel, onChanged: (v) => setState(() => autoModel = v), title: const Text('Auto model & failover'), subtitle: const Text('OpenRouter memilih model tersedia dan mencoba fallback saat gagal.')),
    const SizedBox(height: 8),
    TextField(controller: model, enabled: !autoModel, decoration: const InputDecoration(labelText: 'Model tetap (opsional)', hintText: 'contoh: openai/gpt-4o-mini', prefixIcon: Icon(Icons.psychology_outlined))),
    const SizedBox(height: 8),
    OutlinedButton.icon(onPressed: loadingModels ? null : _discover, icon: const Icon(Icons.sync), label: Text(loadingModels ? 'Mencari model…' : 'Temukan model OpenRouter')),
    if (discovered.isNotEmpty) ...[
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(value: discovered.contains(model.text) ? model.text : null, items: discovered.map((id) => DropdownMenuItem(value: id, child: Text(id, overflow: TextOverflow.ellipsis))).toList(), onChanged: (v) { if (v != null) { model.text = v; setState(() => autoModel = false); } }, decoration: const InputDecoration(labelText: 'Model hasil discovery')),
    ],
    const SizedBox(height: 14),
    TextField(controller: hibp, obscureText: true, decoration: const InputDecoration(labelText: 'HIBP API Key (opsional)', prefixIcon: Icon(Icons.shield_outlined))),
    const SizedBox(height: 14),
    const SizedBox(height: 18),
    Row(children: [Expanded(child: ElevatedButton.icon(onPressed: _save, icon: const Icon(Icons.save_outlined), label: const Text('Simpan'))), const SizedBox(width: 8), Expanded(child: OutlinedButton.icon(onPressed: _testKey, icon: const Icon(Icons.wifi_tethering), label: const Text('Tes API')))]),
    OutlinedButton.icon(onPressed: () { Store.apiKey = null; api.clear(); setState(() {}); }, icon: const Icon(Icons.delete_outline), label: const Text('Hapus API key')),
    OutlinedButton.icon(onPressed: () { Store.clearHistory(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Riwayat chat dihapus.'))); }, icon: const Icon(Icons.history_toggle_off), label: const Text('Hapus riwayat chat')),
    const SizedBox(height: 18),
    OutlinedButton.icon(onPressed: _nuke, icon: const Icon(Icons.warning_amber_rounded), label: const Text('Hapus semua data lokal')),
  ]);
}
