import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../services/ghost_mode.dart';
import '../../widgets/animations.dart';

class VaultNote {
  final String id;
  final String cipher;
  final int ttlMin;
  bool opened;
  int? openedAt;
  VaultNote({
    required this.id,
    required this.cipher,
    required this.ttlMin,
    this.opened = false,
    this.openedAt,
  });
  Map<String, dynamic> toMap() => {
    'id': id, 'cipher': cipher, 'ttl': ttlMin,
    'opened': opened, 'openedAt': openedAt,
  };
  factory VaultNote.fromMap(Map m) => VaultNote(
    id: m['id']?.toString() ?? '',
    cipher: m['cipher']?.toString() ?? '',
    ttlMin: (m['ttl'] as num?)?.toInt() ?? 5,
    opened: m['opened'] == true,
    openedAt: (m['openedAt'] as num?)?.toInt(),
  );
}

class VaultNotesScreen extends StatefulWidget {
  const VaultNotesScreen({super.key});
  @override State<VaultNotesScreen> createState() => _VaultNotesScreenState();
}

class _VaultNotesScreenState extends State<VaultNotesScreen> {
  static const key = 'mzkvlt2026';
  final box = Hive.box('store');
  List<VaultNote> notes = [];
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _load();
    timer = Timer.periodic(const Duration(seconds: 1), (_) => _sweep());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _load() {
    final raw = box.get('vault', defaultValue: <dynamic>[]) as List;
    notes = raw.whereType<Map>().map(VaultNote.fromMap).toList();
    _sweep();
  }

  void _save() => box.put('vault', notes.map((e) => e.toMap()).toList());

  Uint8List _xor(String value) {
    final data = utf8.encode(value);
    final secret = utf8.encode(key);
    return Uint8List.fromList(List.generate(data.length, (i) => data[i] ^ secret[i % secret.length]));
  }

  String _decrypt(String value) {
    try {
      final data = base64Decode(value);
      final secret = utf8.encode(key);
      return utf8.decode(List.generate(data.length, (i) => data[i] ^ secret[i % secret.length]));
    } catch (_) {
      return '[korup/tidak terbaca]';
    }
  }

  void _sweep() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final before = notes.length;
    notes.removeWhere((n) => n.opened && n.openedAt != null &&
      now - n.openedAt! > n.ttlMin * 60000);
    if (notes.length != before) _save();
    if (mounted) setState(() {});
  }

  void _add() {
    final text = TextEditingController();
    int ttl = 5;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: GhostMode.card,
          title: Text('NEW VAULT NOTE', style: TextStyle(color: GhostMode.accent)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: text, maxLines: 4, decoration: const InputDecoration(labelText: 'Isi catatan')),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: ttl,
              decoration: const InputDecoration(labelText: 'Self-destruct setelah dibuka'),
              items: [1, 5, 10, 30, 60].map((m) => DropdownMenuItem(
                value: m, child: Text(m.toString() + ' menit'))).toList(),
              onChanged: (v) => setDialogState(() => ttl = v ?? 5),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                final value = text.text.trim();
                if (value.isEmpty) return;
                notes.add(VaultNote(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  cipher: base64Encode(_xor(value)),
                  ttlMin: ttl,
                ));
                _save();
                setState(() {});
                Navigator.pop(ctx);
              },
              child: const Text('ENCRYPT & SIMPAN'),
            ),
          ],
        ),
      ),
    ).then((_) => text.dispose());
  }

  void _open(int index) {
    final note = notes[index];
    if (!note.opened) {
      note.opened = true;
      note.openedAt = DateTime.now().millisecondsSinceEpoch;
      _save();
      setState(() {});
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text('DECRYPTED', style: TextStyle(color: GhostMode.accent)),
        content: SingleChildScrollView(child: Text(
          _decrypt(note.cipher),
          style: const TextStyle(color: Color(0xFF00FF41), fontFamily: 'monospace'),
        )),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CLOSE'))],
      ),
    );
  }

  String _status(VaultNote note) {
    if (!note.opened || note.openedAt == null) return 'SEALED';
    final left = note.ttlMin * 60000 - (DateTime.now().millisecondsSinceEpoch - note.openedAt!);
    if (left <= 0) return 'DELETING...';
    final min = left ~/ 60000;
    final sec = (left % 60000) ~/ 1000;
    return min.toString() + ':' + sec.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GhostMode.bg,
      appBar: AppBar(
        backgroundColor: GhostMode.card,
        title: ValueListenableBuilder<bool>(
          valueListenable: GhostMode.active,
          builder: (_, ghost, __) => Text(
            ghost ? '[REDACTED]' : 'AUTO-DESTRUCT VAULT',
            style: TextStyle(color: GhostMode.accent, letterSpacing: 2),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: GhostMode.accent, onPressed: _add, child: const Icon(Icons.add)),
      body: PageFade(
        child: notes.isEmpty
          ? Center(child: Text(
              GhostMode.active.value ? '[REDACTED]' : 'Tidak ada catatan aktif.',
              textAlign: TextAlign.center, style: const TextStyle(color: Colors.white38)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notes.length,
              itemBuilder: (_, i) {
                final note = notes[i];
                return PopIn(
                  delayMs: (i * 50).clamp(0, 500).toInt(),
                  child: Card(child: ListTile(
                    onTap: () => _open(i),
                    leading: Icon(note.opened ? Icons.local_fire_department : Icons.lock,
                      color: note.opened ? Colors.orange : GhostMode.accent),
                    title: Text('NOTE #' + note.id.substring(note.id.length > 4 ? note.id.length - 4 : 0)),
                    subtitle: Text('TTL ' + note.ttlMin.toString() + 'm • ' + _status(note)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () { notes.removeAt(i); _save(); setState(() {}); },
                    ),
                  )),
                );
              },
            ),
      ),
    );
  }
}
