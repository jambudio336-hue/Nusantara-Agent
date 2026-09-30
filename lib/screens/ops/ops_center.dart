import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets/animations.dart';
import '../../widgets/responsive.dart';
import 'threat_feed.dart';
import 'ip_scanner.dart';
import 'ssl_auditor.dart';
import 'breach_monitor.dart';
import 'paste_monitor.dart';
import 'dashboard.dart';

class OpsCenter extends StatelessWidget {
  const OpsCenter({super.key});

  static const items = [
    ['Threat Feed', Icons.warning_amber, 'CVE & KEV real-time', ThreatFeedScreen()],
    ['IP Scanner', Icons.my_location, 'IP intel & reputasi', IpScannerScreen()],
    ['SSL Auditor', Icons.security, 'Audit sertifikat domain', SslAuditorScreen()],
    ['Breach Monitor', Icons.broken_image, 'Breach check & timeline', BreachMonitorScreen()],
    ['Paste Hunter', Icons.search, 'Cari referensi paste publik', PasteMonitorScreen()],
    ['Dashboard', Icons.dashboard, 'Target tracker operasi', OpsDashboardScreen()],
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return MzScaffold(
      title: 'OPS CENTER',
      body: PageFade(
        child: GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: w > 420 ? 3 : 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final it = items[i];
            return PopIn(
              delayMs: i * 60,
              child: Pressable(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => it[3] as Widget),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: MzTheme.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: MzTheme.red.withOpacity(.3)),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(it[1] as IconData,
                          color: MzTheme.red, size: fz(context, 36)),
                      const SizedBox(height: 10),
                      Text(it[0] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: fz(context, 14))),
                      const SizedBox(height: 4),
                      Text(it[2] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
