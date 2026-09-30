import 'package:flutter/material.dart';
import '../../services/targets_store.dart';
import '../../widgets/responsive.dart';

class OpsDashboardScreen extends StatefulWidget {
  const OpsDashboardScreen({super.key});
  @override
  State<OpsDashboardScreen> createState() => _OpsDashboardScreenState();
}
class _OpsDashboardScreenState extends State<OpsDashboardScreen> {
  final _controller = TextEditingController();
  void _add() {
    final target = _controller.text.trim();
    if (target.isEmpty) return;
    TargetsStore.add(TargetEntry(
      target: target,
      type: RegExp(r'^$d{1,3}($.$d{1,3}){3}$').hasMatch(target) ? 'ip' : 'domain',
      date: DateTime.now().toIso8601String(),
    ));
    _controller.clear();
    setState(() {});
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => MzScaffold(
    title: 'OPS DASHBOARD',
    fab: FloatingActionButton(onPressed: _add, child: const Icon(Icons.add)),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      TextField(controller: _controller, decoration: const InputDecoration(labelText: 'Authorized IP / domain')),
      const SizedBox(height: 16),
      ...TargetsStore.all.asMap().entries.map((entry) {
        final i = entry.key;
        final t = entry.value;
        return Card(child: ListTile(
          title: Text(t.target),
          subtitle: Text('${t.type} • ${t.status}${t.notes.isEmpty ? '' : '$n${t.notes}'}'),
          trailing: PopupMenuButton<String>(
            onSelected: (status) { TargetsStore.updateStatus(i, status, t.notes); setState(() {}); },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'recon', child: Text('recon')),
              PopupMenuItem(value: 'scanning', child: Text('scanning')),
              PopupMenuItem(value: 'done', child: Text('done')),
              PopupMenuItem(value: 'rooted', child: Text('rooted')),
            ],
          ),
        ));
      }),
    ]),
  );
}
