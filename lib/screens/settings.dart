import 'package:flutter/material.dart';

import '../services/storage.dart';
import '../theme.dart';

const MODELS = [
  'openai/gpt-4o-mini',
  'openai/gpt-4o',
  'anthropic/claude-sonnet-4',
  'deepseek/deepseek-chat',
  'google/gemini-2.0-flash-001',
  'meta-llama/llama-3.1-405b-instruct',
];

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController keyCtrl;
  late final TextEditingController capitalCtrl;
  late String model;
  bool obscureKey = true;

  @override
  void initState() {
    super.initState();
    keyCtrl = TextEditingController(text: Store.apiKey ?? '');
    model = MODELS.contains(Store.model) ? Store.model : MODELS.first;
    capitalCtrl = TextEditingController(
      text: Store.capital.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    keyCtrl.dispose();
    capitalCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final key = keyCtrl.text.trim();
    final capital = double.tryParse(
          capitalCtrl.text.trim().replaceAll(',', '.'),
        ) ??
        1000;

    Store.apiKey = key.isEmpty ? null : key;
    Store.model = model;
    Store.capital = capital < 0 ? 0 : capital;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: MzTheme.red,
        content: Text('✅ Pengaturan tersimpan di storage HP'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'OpenRouter API Key',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Dapatkan API key dari OpenRouter. Key disimpan lokal di perangkat.',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: keyCtrl,
            obscureText: obscureKey,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              hintText: 'sk-or-v1-...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                tooltip: obscureKey ? 'Tampilkan API key' : 'Sembunyikan API key',
                icon: Icon(
                  obscureKey
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () {
                  setState(() => obscureKey = !obscureKey);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Model AI',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: model,
            dropdownColor: MzTheme.card,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: MODELS
                .map(
                  (m) => DropdownMenuItem<String>(
                    value: m,
                    child: Text(
                      m,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => model = v);
              }
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Modal Awal Jurnal Trading ($)',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: capitalCtrl,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixText: '$ ',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: MzTheme.red,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: _save,
            child: const Text(
              'SIMPAN',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
