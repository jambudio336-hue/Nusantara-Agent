import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets/responsive.dart';

class PasteMonitorScreen extends StatelessWidget {
  const PasteMonitorScreen({super.key});
  @override
  Widget build(BuildContext context) => MzScaffold(
    title: 'PASTE HUNTER',
    body: ListView(padding: const EdgeInsets.all(16), children: const [
      Icon(Icons.search, color: MzTheme.red, size: 56),
      SizedBox(height: 16),
      Text('Public Paste Monitor', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      SizedBox(height: 10),
      Text('Modul ini disiapkan untuk pencarian sumber paste publik yang sah. Jangan gunakan untuk mencari, mengumpulkan, atau menyebarkan kredensial atau data pribadi yang bocor.',
        textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
    ]),
  );
}
