import 'dart:async';
import 'package:flutter/material.dart';
import '../services/openrouter.dart';
import '../services/intel_api.dart';
import '../theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  bool loading = true;
  String aiStatus = 'CHECKING';
  String securityStatus = 'CHECKING';
  int cves = 0;
  String? error;
  DateTime? lastSync;
  Timer? _timer;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800), lowerBound: .88, upperBound: 1)..repeat(reverse: true);
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => _refresh(silent: true));
  }
  @override
  void dispose() { _timer?.cancel(); _pulse.dispose(); super.dispose(); }

  Future<void> _refresh({bool silent = false}) async {
    if (!silent && mounted) setState(() { loading = true; error = null; });
    try {
      final results = await Future.wait([OpenRouter.models(), IntelApi.recentCves()]);
      if (!mounted) return;
      setState(() { aiStatus = (results[0] as List).isNotEmpty ? 'ONLINE' : 'EMPTY'; cves = (results[1] as List).length; securityStatus = 'LIVE'; loading = false; lastSync = DateTime.now(); });
    } catch (e) {
      if (!mounted) return;
      setState(() { aiStatus = 'CHECK FAILED'; securityStatus = 'STALE'; error = e.toString(); loading = false; lastSync = DateTime.now(); });
    }
  }

  Widget _metric(IconData icon, String title, String value, Color color) => Expanded(child: AnimatedBuilder(animation: _pulse, builder: (_, __) => Transform.scale(scale: value == 'ONLINE' || value == 'LIVE' ? _pulse.value : 1, child: Container(margin: const EdgeInsets.all(5), padding: const EdgeInsets.all(15), decoration: BoxDecoration(gradient: LinearGradient(colors: [color.withValues(alpha: .20), MzTheme.card]), borderRadius: BorderRadius.circular(18), border: Border.all(color: color.withValues(alpha: .35)), boxShadow: [BoxShadow(color: color.withValues(alpha: .10), blurRadius: 20)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color, size: 25), const SizedBox(height: 12), Text(title, style: const TextStyle(color: Colors.white54, fontSize: 11)), const SizedBox(height: 3), Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18))])))));
  Widget _action(IconData icon, String label, Color color, VoidCallback onTap) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: AnimatedContainer(duration: const Duration(milliseconds: 220), width: 145, padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: MzTheme.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: .25))), child: Row(children: [Icon(icon, color: color), const SizedBox(width: 9), Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))])));

  @override
  Widget build(BuildContext context) => RefreshIndicator(onRefresh: _refresh, child: ListView(padding: const EdgeInsets.fromLTRB(14, 12, 14, 28), children: [
    AnimatedBuilder(animation: _pulse, builder: (_, __) => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF25145E), Color(0xFF101D4D), Color(0xFF082C3A)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(24), border: Border.all(color: MzTheme.cyan.withValues(alpha: .30)), boxShadow: [BoxShadow(color: const Color(0x331AABFF), blurRadius: 28 * _pulse.value)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('MAZKIPLAY AI', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900, letterSpacing: 2)), const SizedBox(height: 6), const Text('ONLINE INTELLIGENCE CONSOLE', style: TextStyle(color: MzTheme.cyan, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)), const SizedBox(height: 18), Row(children: [Container(width: 9, height: 9, decoration: const BoxDecoration(color: MzTheme.green, shape: BoxShape.circle)), const SizedBox(width: 8), Expanded(child: Text(loading ? 'Synchronizing live services…' : 'Live services synchronized.', style: const TextStyle(color: Colors.white70))), Text(lastSync == null ? '--:--' : '${lastSync!.hour.toString().padLeft(2, '0')}:${lastSync!.minute.toString().padLeft(2, '0')}', style: const TextStyle(color: Colors.white38, fontSize: 11))])]))),
    const SizedBox(height: 12), Row(children: [_metric(Icons.auto_awesome, 'OPENROUTER', aiStatus, MzTheme.purple), _metric(Icons.security, 'SECURITY FEED', securityStatus, MzTheme.cyan)]),
    Row(children: [_metric(Icons.bug_report, 'RECENT CVEs', cves.toString(), MzTheme.red), _metric(Icons.cloud_done, 'NETWORK', loading ? 'SYNC' : 'ONLINE', Colors.greenAccent)]),
    if (error != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(error!, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.orangeAccent, fontSize: 11))),
    const SizedBox(height: 16), const Text('QUICK ACTIONS', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, letterSpacing: 1.2)), const SizedBox(height: 10),
    Wrap(spacing: 9, runSpacing: 9, children: [_action(Icons.refresh_rounded, 'Sync Online', MzTheme.cyan, _refresh), _action(Icons.auto_awesome, 'AI Models', MzTheme.purple, _refresh), _action(Icons.bug_report, 'CVE Feed', MzTheme.red, _refresh), _action(Icons.speed, 'Live Status', Colors.greenAccent, _refresh)]),
    const SizedBox(height: 18),
    Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('AI ENGINE ACTIVE', style: TextStyle(color: MzTheme.cyan, fontWeight: FontWeight.w900, letterSpacing: 1)), const SizedBox(height: 10), const Text('✓ OpenRouter direct request\n✓ Auto model discovery & failover\n✓ Bahasa Indonesia friendly + structured output\n✓ Coding, data, trading research, OSINT publik\n✓ Security defensif dan authorized testing\n✓ Image/file attachment workflow', style: TextStyle(color: Colors.white70, height: 1.55)), const SizedBox(height: 10), const Text('AI tidak menjalankan serangan tanpa izin dan tidak mengarang data live.', style: TextStyle(color: Colors.orangeAccent, fontSize: 11))]))),
    const SizedBox(height: 12),
    Card(child: Padding(padding: const EdgeInsets.all(16), child: const Text('ONLINE-FIRST MODE\nData dan AI diambil dari layanan online. API key tetap disimpan lokal di perangkat; aplikasi tidak menanam secret di backend. Dashboard refresh otomatis setiap 20 detik.', style: TextStyle(color: Colors.white60, height: 1.45)))),
  ]);
}
