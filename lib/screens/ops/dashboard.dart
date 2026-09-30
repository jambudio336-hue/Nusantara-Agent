import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets/animations.dart';
import '../../widgets/responsive.dart';
import '../../services/targets_store.dart';

const STATUSES = ['recon', 'scanning', 'done', 'rooted'];

class OpsDashboardScreen extends StatefulWidget {
  const OpsDashboardScreen({super.key});
  @override State<OpsDashboardScreen> createState() => _OpsDashboardScreenState();
}

class _OpsDashboardScreenState extends State<OpsDashboardScreen> {
  List<TargetEntry> targets = [];

  @override void initState() {
    super.initState();
    targets = TargetsStore.all;
  }

  void _add() {
    final controller = TextEditingController();
    String type = 'domain';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: MzTheme.cardAlt,
          title: const Text('Tambah Target'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: controller, decoration: const InputDecoration(labelText: 'IP / Domain')),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: type,
              items: const [
                DropdownMenuItem(value: 'domain', child: Text('Domain')),
                DropdownMenuItem(value: 'ip', child: Text('IP')),
              ],
              onChanged: (v) => setDialogState(() => type = v ?? type),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                final target = controller.text.trim();
                if (target.isEmpty) return;
                TargetsStore.add(TargetEntry(
                  target: target,
                  type: type,
                  date: DateTime.now().toIso8601String().substring(0, 10),
                ));
                setState(() => targets = TargetsStore.all);
                Navigator.pop(ctx);
              },
              child: const Text('Tambah'),
            ),
          ],
        ),
      ),
    ).then((_) => controller.dispose());
  }

  Color _statusColor(String s) {
    if (s == 'recon') return Colors.blueGrey;
    if (s == 'scanning') return Colors.orange;
    if (s == 'done') return Colors.green;
    if (s == 'rooted') return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{
      for (final s in STATUSES) s: targets.where((t) => t.status == s).length,
    };
    return Scaffold(
      backgroundColor: MzTheme.bg,
      appBar: AppBar(title: const Text('OPERATION DASHBOARD',
        style: TextStyle(color: MzTheme.red, letterSpacing: 2))),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MzTheme.red, onPressed: _add, child: const Icon(Icons.add)),
      body: PageFade(child: ListView(padding: const EdgeInsets.all(16), children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: STATUSES.map((s) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PopIn(
              delayMs: STATUSES.indexOf(s) * 80,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: MzTheme.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _statusColor(s).withValues(alpha: 0.6)),
                ),
                child: Column(children: [
                  Text(counts[s].toString(),
                    style: TextStyle(color: _statusColor(s), fontSize: fz(context, 22), fontWeight: FontWeight.w900)),
                  Text(s.toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 10)),
                ]),
              ),
            ),
          )).toList()),
        ),
        const SizedBox(height: 20),
        if (targets.isEmpty)
          const Center(child: Text(
            'Belum ada target.\nTambah manual atau scan via IP Scanner / SSL Auditor.',
            textAlign: TextAlign.center, style: TextStyle(color: Colors.white38)))
        else
          ...targets.asMap().entries.map((entry) {
            final index = entry.key;
            final target = entry.value;
            final note = target.notes.isEmpty ? '' : ' • ' + target.notes;
            return PopIn(
              delayMs: (index * 50).clamp(0, 500).toInt(),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: MzTheme.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(target.target, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text(target.type + ' • ' + target.date + note,
                        style: const TextStyle(color: Colors.white38, fontSize: 11)),
                    ],
                  )),
                  DropdownButton<String>(
                    value: STATUSES.contains(target.status) ? target.status : STATUSES.first,
                    dropdownColor: MzTheme.cardAlt,
                    underline: const SizedBox(),
                    items: STATUSES.map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s.toUpperCase(), style: TextStyle(color: _statusColor(s), fontSize: 12)),
                    )).toList(),
                    onChanged: (v) {
                      TargetsStore.updateStatus(index, v ?? target.status, target.notes);
                      setState(() => targets = TargetsStore.all);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white38, size: 18),
                    onPressed: () {
                      TargetsStore.remove(index);
                      setState(() => targets = TargetsStore.all);
                    },
                  ),
                ]),
              ),
            );
          }),
      ])),
    );
  }
}
