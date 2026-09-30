import 'package:flutter/material.dart';

import '../services/storage.dart';
import 'settings.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  StorageService get _storage => StorageScope.of(context);

  Future<void> _addEntry() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Journal baru'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Judul'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                minLines: 4,
                maxLines: 8,
                decoration: const InputDecoration(labelText: 'Catatan'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result != true) {
      titleController.dispose();
      contentController.dispose();
      return;
    }

    await _storage.addJournalEntry(
      title: titleController.text,
      content: contentController.text,
    );

    titleController.dispose();
    contentController.dispose();

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final entries = _storage.journalEntries;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _addEntry,
        child: const Icon(Icons.add),
      ),
      body: entries.isEmpty
          ? const Center(
              child: Text(
                'Belum ada journal.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final item = entries[index];
                return Card(
                  child: ExpansionTile(
                    leading: const Icon(Icons.book_outlined),
                    title: Text(item['title']?.toString() ?? 'Tanpa judul'),
                    subtitle: Text(
                      item['createdAt']?.toString() ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(item['content']?.toString() ?? ''),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () async {
                            await _storage.deleteJournalEntry(index);
                            if (mounted) setState(() {});
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Hapus'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
