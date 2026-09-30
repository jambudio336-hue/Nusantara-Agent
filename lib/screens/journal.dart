import 'package:flutter/material.dart';
import '../services/storage.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});
  @override State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  Future<void> _addEntry() async {
    final title = TextEditingController();
    final content = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Journal baru'),
        content: SingleChildScrollView(child: Column(children: [
          TextField(controller: title, decoration: const InputDecoration(labelText: 'Judul')),
          const SizedBox(height: 12),
          TextField(controller: content, minLines: 4, maxLines: 8,
            decoration: const InputDecoration(labelText: 'Catatan')),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Simpan')),
        ],
      ),
    );
    if (ok == true && title.text.trim().isNotEmpty && content.text.trim().isNotEmpty) {
      Store.addJournalEntry(title: title.text.trim(), content: content.text.trim());
      if (mounted) setState(() {});
    }
    title.dispose();
    content.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = Store.journalEntries;
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: _addEntry, child: const Icon(Icons.add)),
      body: entries.isEmpty
          ? const Center(child: Text('Belum ada journal.', style: TextStyle(color: Colors.white70)))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final item = entries[i];
                return Card(child: ExpansionTile(
                  leading: const Icon(Icons.book_outlined),
                  title: Text(item['title']?.toString() ?? 'Tanpa judul'),
                  subtitle: Text(item['createdAt']?.toString() ?? ''),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    Align(alignment: Alignment.centerLeft,
                      child: Text(item['content']?.toString() ?? '')),
                    Align(alignment: Alignment.centerRight, child: TextButton.icon(
                      onPressed: () async {
                        Store.deleteJournalEntry(i);
                        if (mounted) setState(() {});
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Hapus'),
                    )),
                  ],
                ));
              },
            ),
    );
  }
}
