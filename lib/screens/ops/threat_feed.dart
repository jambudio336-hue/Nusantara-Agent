import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets/animations.dart';
import '../../widgets/responsive.dart';
import '../../services/intel_api.dart';

class ThreatFeedScreen extends StatefulWidget {
  const ThreatFeedScreen({super.key});
  @override
  State<ThreatFeedScreen> createState() => _ThreatFeedScreenState();
}
class _ThreatFeedScreenState extends State<ThreatFeedScreen> {
  List<dynamic> kev = [], cves = [];
  bool loading = true;
  String error = '';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (mounted) setState(() { loading = true; error = ''; });
    try {
      final results = await Future.wait([IntelApi.kev(), IntelApi.recentCves()]);
      if (!mounted) return;
      setState(() { kev = results[0]; cves = results[1]; loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { error = 'Gagal fetch intel: $e'; loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Scaffold(
      backgroundColor: MzTheme.bg,
      appBar: AppBar(
        title: const Text('THREAT INTEL', style: TextStyle(color: MzTheme.red, letterSpacing: 2)),
        bottom: const TabBar(indicatorColor: MzTheme.red,
          tabs: [Tab(text: 'CISA KEV'), Tab(text: 'CVE Terbaru (NVD)')]),
      ),
      body: loading
        ? const Center(child: CircularProgressIndicator(color: MzTheme.red))
        : error.isNotEmpty
          ? Center(child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(error, textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent))))
          : TabBarView(children: [_kevList(), _cveList()]),
    ),
  );

  Widget _kevList() => RefreshIndicator(
    color: MzTheme.red, onRefresh: _load,
    child: ListView.builder(
      padding: const EdgeInsets.all(12), itemCount: kev.length,
      itemBuilder: (_, i) {
        final v = Map<String, dynamic>.from(kev[i] as Map);
        return PopIn(delayMs: (i * 30).clamp(0, 300), child: _vulnCard(
          v['cveID']?.toString() ?? '',
          v['vendorProject']?.toString() ?? '',
          v['vulnerabilityName']?.toString() ?? '',
          'Date added: ${v['dateAdded'] ?? '-'}',
          critical: true,
        ));
      },
    ),
  );

  Widget _cveList() => RefreshIndicator(
    color: MzTheme.red, onRefresh: _load,
    child: ListView.builder(
      padding: const EdgeInsets.all(12), itemCount: cves.length,
      itemBuilder: (_, i) {
        final root = Map<String, dynamic>.from(cves[i] as Map);
        final c = Map<String, dynamic>.from(root['cve'] as Map? ?? {});
        final metrics = Map<String, dynamic>.from(c['metrics'] as Map? ?? {});
        double? cvss;
        final metric31 = metrics['cvssMetricV31'];
        if (metric31 is List && metric31.isNotEmpty) {
          final first = metric31.first;
          if (first is Map && first['cvssData'] is Map) {
            final score = (first['cvssData'] as Map)['baseScore'];
            if (score is num) cvss = score.toDouble();
          }
        }
        String description = '';
        final descriptions = c['descriptions'];
        if (descriptions is List) {
          final english = descriptions.whereType<Map>()
            .where((d) => d['lang'] == 'en')
            .map((d) => d['value']?.toString() ?? '').toList();
          description = english.isEmpty ? '' : english.first;
        }
        return PopIn(delayMs: (i * 30).clamp(0, 300), child: _vulnCard(
          c['id']?.toString() ?? '', description,
          cvss != null ? 'CVSS: $cvss' : 'CVSS: N/A',
          'Published: ${c['published'] ?? '-'}',
          critical: (cvss ?? 0) >= 9,
        ));
      },
    ),
  );

  Widget _vulnCard(String id, String desc, String meta, String date,
      {required bool critical}) => Container(
    margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: MzTheme.card, borderRadius: BorderRadius.circular(12),
      border: Border(left: BorderSide(color: critical ? Colors.red : Colors.orange, width: 4))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(id, style: const TextStyle(color: MzTheme.red, fontWeight: FontWeight.bold))),
        if (critical) Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
          child: const Text('WEAPONIZED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
      ]),
      const SizedBox(height: 6),
      Text(desc.isEmpty ? 'No English description available.' : desc, maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.white70, fontSize: fz(context, 13))),
      const SizedBox(height: 6),
      Text('$meta • $date', style: const TextStyle(color: Colors.white38, fontSize: 11)),
    ]),
  );
}
