import 'package:flutter/material.dart';

import '../services/storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _apiKeyController;
  late final TextEditingController _modelController;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(text: Store.apiKey ?? '');
    _modelController = TextEditingController(text: Store.model);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    Store.apiKey = _apiKeyController.text.trim().isEmpty
        ? null
        : _apiKeyController.text.trim();
    Store.model = _modelController.text.trim().isEmpty
        ? 'openai/gpt-4o-mini'
        : _modelController.text.trim();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengaturan disimpan.')),
    );
    setState(() {});
  }

  Future<void> _clearKey() async {
    Store.apiKey = null;
    _apiKeyController.clear();
    if (mounted) setState(() {});
  }

  Future<void> _clearHistory() async {
    Store.clearHistory();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Riwayat chat dihapus.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          Store.hasKey
              ? 'OpenRouter siap digunakan.'
              : 'Masukkan API key OpenRouter untuk mengaktifkan chat.',
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 22),
        TextField(
          controller: _apiKeyController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'OpenRouter API Key',
            prefixIcon: Icon(Icons.key_outlined),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _modelController,
          decoration: const InputDecoration(
            labelText: 'Model',
            prefixIcon: Icon(Icons.psychology_outlined),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Simpan'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _clearKey,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Hapus API Key'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _clearHistory,
          icon: const Icon(Icons.history_toggle_off),
          label: const Text('Hapus Riwayat Chat'),
        ),
        const SizedBox(height: 24),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'API key disimpan lokal di perangkat dan tidak ditanam di source code.',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ],
    );
  }
}
