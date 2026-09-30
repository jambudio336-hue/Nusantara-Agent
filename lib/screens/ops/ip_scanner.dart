import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets/animations.dart';
import '../../widgets/responsive.dart';
import '../../services/intel_api.dart';
import '../../services/targets_store.dart';

class IpScannerScreen extends StatefulWidget {
  const IpScannerScreen({super.key});
  @override
  State<IpScannerScreen> createState() => _IpScannerScreenState();
}
class _IpScannerScreenState extends State<IpScannerScreen> {
  final ctrl = TextEditingController();
  Map<String, dynamic>? result;
  bool loading = false;

  Future<void> scan() async {
    final ip = ctrl.text.trim();
    if (ip.isEmpty || loading) return;
    setState(() { loading = true; result = null; });
    try {
      final r = await IntelApi.ipInfo(ip);
      if (!mounted) return;
      setState(() => result = r);
      TargetsStore.add(TargetEntry(
        target: ip, type: 'ip',
        status: r['status'] == 'success' ? 'done' : 'recon',
        notes: '${r['isp'] ?? ''} ${r['country'] ?? ''}'.trim(),
        date: DateTime.now().toIso8601String().substring(0, 10),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: MzTheme.red, content: Text('Scan gagal: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() { ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: MzTheme.bg,
    appBar: AppBar(title: const Text('IP INTEL SCANNER',
      style: TextStyle(color: MzTheme.red, letterSpacing: 2))),
    body: PageFade(
      child: ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [
          Expanded(child: TextField(
            controller: ctrl, style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.url,
            decoration: InputDecoration(hintText: 'contoh: 8.8.8.8',
              hintStyle: TextStyle(color: Colors.grey.shade600), filled: true,
              fillColor: MzTheme.card,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none)),
            onSubmitted: (_) => scan())),
          const SizedBox(width: 10),
          Pressable(
            onTap: loading ? () {} : scan,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: MzTheme.red, borderRadius: BorderRadius.circular(12)),
              child: loading
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.radar, color: Colors.white),
            ),
          ),
        ]),
        const SizedBox(height: 20),
        if (result != null) PopIn(child: _resultCard(result!)),
      ]),
    ),
  );

  Widget _resultCard(Map<String, dynamic> r) {
    final ok = r['status'] == 'success';
    if (!ok) return const Text('❌ IP tidak ditemukan / query gagal',
      style: TextStyle(color: Colors.redAccent));
    final rows = {
      'IP': r['query'], 'Negara': '${r['country']} (${r['countryCode']})',
      'ISP': r['isp'], 'Org': r['org'], 'AS': r['as'],
      'Kota/Wilayah': '${r['city']}, ${r['regionName']}',
      'Zona Waktu': r['timezone'],
      'Proxy/VPN': r['proxy'] == true ? '⚠ YA — IP ini proxy/VPN' : 'Tidak',
      'Hosting/Datacenter': r['hosting'] == true ? '⚠ YA — server/hosting' : 'Tidak',
      'Mobile': r['mobile'] == true ? 'Ya' : 'Tidak',
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: MzTheme.card, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MzTheme.red.withOpacity(.3))),
      child: Column(children: rows.entries.map((e) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 110, child: Text(e.key,
            style: const TextStyle(color: Colors.white38, fontSize: 13))),
          Expanded(child: Text('${e.value}', style: TextStyle(
            color: e.value.toString().startsWith('⚠') ? Colors.orangeAccent : Colors.white,
            fontSize: 13, fontWeight: FontWeight.w500))),
        ]),
      )).toList()),
    );
  }
}
