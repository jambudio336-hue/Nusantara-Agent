import 'package:flutter/material.dart';
import '../services/openrouter.dart';
import '../services/intel_api.dart';
import '../theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool loading = true;
  String aiStatus = 'CHECKING';
  String securityStatus = 'CHECKING';
  int cves = 0;
  String? error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() { loading = true; error = null; });
    try {
      final results = await Future.wait([
        OpenRouter.models(),
        IntelApi.recentCves(),
      ]);
      if (!mounted) return;
      setState(() {
        aiStatus = (results[0] as List).isNotEmpty ? 'ONLINE' : 'EMPTY';
        cves = (results[1] as List).length;
        securityStatus = 'LIVE';
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        aiStatus = 'CHECK FAILED';
        securityStatus = 'CHECK FAILED';
        error = e.toString();
        loading = false;
      });
    }
  }

  Widget _metric(BuildContext context, IconData icon, String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: .20), MzTheme.card],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: .35)),
          boxShadow: [BoxShadow(color: color.withValues(alpha: .08), blurRadius: 18)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 25),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.white54, fontSize: 11)),
            const SizedBox(height: 3),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _action(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 145,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: MzTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: .25)),
        ),
        child: Row(children: [
          Icon(icon, color: color),
          const SizedBox(width: 9),
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF25145E), Color(0xFF101D4D), Color(0xFF082C3A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: MzTheme.cyan.withValues(alpha: .30)),
              boxShadow: const [BoxShadow(color: Color(0x331AABFF), blurRadius: 28)],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('MAZKIPLAY AI', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900, letterSpacing: 2)),
              const SizedBox(height: 6),
              const Text('ONLINE INTELLIGENCE CONSOLE', style: TextStyle(color: MzTheme.cyan, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
              const SizedBox(height: 18),
              Text(
                loading ? 'Synchronizing live services…' : 'Live services synchronized.',
                style: const TextStyle(color: Colors.white70),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          Row(children: [
            _metric(context, Icons.auto_awesome, 'OPENROUTER', aiStatus, MzTheme.purple),
            _metric(context, Icons.security, 'SECURITY FEED', securityStatus, MzTheme.cyan),
          ]),
          Row(children: [
            _metric(context, Icons.bug_report, 'RECENT CVEs', cves.toString(), MzTheme.red),
            _metric(context, Icons.cloud_done, 'NETWORK', loading ? 'SYNC' : 'ONLINE', Colors.greenAccent),
          ]),
          if (error != null)
            Padding(padding: const EdgeInsets.only(top: 10), child: Text(error!, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.orangeAccent, fontSize: 11))),
          const SizedBox(height: 16),
          const Text('QUICK ACTIONS', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          const SizedBox(height: 10),
          Wrap(spacing: 9, runSpacing: 9, children: [
            _action(context, Icons.refresh_rounded, 'Sync Online', MzTheme.cyan, _refresh),
            _action(context, Icons.auto_awesome, 'AI Models', MzTheme.purple, () => _refresh()),
            _action(context, Icons.bug_report, 'CVE Feed', MzTheme.red, () => _refresh()),
            _action(context, Icons.speed, 'Live Status', Colors.greenAccent, () => _refresh()),
          ]),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: MzTheme.card, borderRadius: BorderRadius.circular(18)),
            child: const Text(
              'ONLINE-FIRST MODE\nAI dan intelligence mengambil data dari layanan online. API key tetap disimpan lokal di perangkat; aplikasi tidak menanam secret di backend.',
              style: TextStyle(color: Colors.white60, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
