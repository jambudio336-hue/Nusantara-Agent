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

  StorageService get _storage => StorageScope.of(context);

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    _modelController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_apiKeyController.text.isEmpty) {
      _apiKeyController.text = _storage.apiKey ?? '';
      _modelController.text = _storage.model;
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await _storage.saveApiKey(_apiKeyController.text);
    await _storage.saveModel(_modelController.text);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengaturan disimpan.')),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final configured = (_storage.apiKey ?? '').isNotEmpty;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          configured
              ? 'OpenRouter terkonfigurasi.'
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
          onPressed: () async {
            await _storage.clearApiKey();
            _apiKeyController.clear();
            if (mounted) setState(() {});
          },
          icon: const Icon(Icons.delete_outline),
          label: const Text('Hapus API Key'),
        ),
        const SizedBox(height: 24),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'API key disimpan lokal menggunakan SharedPreferences dan tidak ditanam di source code.',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ],
    );
  }
}

class StorageScope extends InheritedWidget {
  final StorageService storage;

  const StorageScope({
    super.key,
    required this.storage,
    required super.child,
  });

  static StorageService of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<StorageScope>();
    assert(scope != null, 'StorageScope tidak tersedia.');
    return scope!.storage;
  }

  @override
  bool updateShouldNotify(StorageScope oldWidget) => storage != oldWidget.storage;
}
