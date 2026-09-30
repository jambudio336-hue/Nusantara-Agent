import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/market_data.dart';
import '../services/openrouter.dart';
import '../theme.dart';

class TradingScreen extends StatefulWidget {
  const TradingScreen({super.key});
  @override State<TradingScreen> createState() => _TradingState();
}

class _TradingState extends State<TradingScreen> {
  String symbol = 'EURUSD';
  String tf = '15';
  String analysis = '';
  late WebViewController _chart;
  bool chartLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChart();
  }

  void _loadChart() {
    chartLoading = true;
    _chart = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(MzTheme.bg)
      ..setNavigationDelegate(NavigationDelegate(onPageFinished: (_) { if (mounted) setState(() => chartLoading = false); }))
      ..loadRequest(MarketData.chartUri(symbol, tf));
  }

  void _changeSymbol(String next) { setState(() { symbol = next; _loadChart(); }); }

  Future<void> _aiSignal() async {
    setState(() => analysis = 'AI sedang menggabungkan konteks teknikal, fundamental publik, dan risiko...');
    final prompt = '''Analisis trading $symbol pada timeframe $tf menit menggunakan chart TradingView publik.
Berikan output profesional dalam bahasa Indonesia dengan urutan:
1) data yang tersedia dan timestamp/sumber;
2) trend dan market structure (BOS, CHoCH, fakeout, supply-demand, liquidity);
3) EMA, RSI, Bollinger Bands, ATR, volume, support/resistance, Fibonacci;
4) fundamental/macro dan kalender Forex Factory jika benar-benar tersedia;
5) analisis multi-timeframe;
6) skenario BUY, SELL, dan WAIT;
7) jika setup valid, entry, SL, TP1-TP3, R:R, estimasi risiko dan alasan.
Jangan mengarang harga atau berita live. Jika tidak ada raw candle/fundamental terverifikasi di konteks request, katakan dengan jelas bahwa pengguna harus memverifikasi chart dan kalender secara langsung. Ini bukan nasihat finansial.''';
    final result = await OpenRouter.chat([{'role': 'user', 'content': prompt}]);
    if (mounted) setState(() => analysis = result);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('$symbol • TradingView'), actions: [IconButton(onPressed: _loadChart, icon: const Icon(Icons.refresh))]),
    body: ListView(padding: const EdgeInsets.all(12), children: [
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: MarketData.forex.map((s) => Padding(padding: const EdgeInsets.only(right: 6), child: ChoiceChip(label: Text(s), selected: s == symbol, onSelected: (_) => _changeSymbol(s)))).toList())),
      const SizedBox(height: 8),
      Row(children: [Expanded(child: DropdownButtonFormField<String>(value: tf, items: MarketData.timeframes.map((x) => DropdownMenuItem(value: x, child: Text(x == 'D' || x == 'W' || x == 'M' ? x : '${x}m'))).toList(), onChanged: (x) { if (x != null) { setState(() { tf = x; _loadChart(); }); } }, decoration: const InputDecoration(labelText: 'Timeframe'))), const SizedBox(width: 8), Expanded(child: FilledButton.icon(onPressed: _aiSignal, icon: const Icon(Icons.auto_awesome), label: const Text('ANALISA AI')))]),
      const SizedBox(height: 8),
      SizedBox(height: 460, child: Stack(children: [ClipRRect(borderRadius: BorderRadius.circular(16), child: WebViewWidget(controller: _chart)), if (chartLoading) const Center(child: CircularProgressIndicator())])),
      if (analysis.isNotEmpty) Container(margin: const EdgeInsets.only(top: 10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: MzTheme.card, borderRadius: BorderRadius.circular(16)), child: SelectableText(analysis, style: const TextStyle(color: Colors.white70, height: 1.45))),
      Container(margin: const EdgeInsets.only(top: 10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: MzTheme.card, borderRadius: BorderRadius.circular(16)), child: const Text('Chart ditampilkan online dari TradingView. Tombol ANALISA AI memakai konteks simbol/timeframe dan tidak boleh dianggap sebagai jaminan profit. Verifikasi harga, volume, kalender ekonomi, spread, dan risiko sebelum mengambil keputusan.', style: TextStyle(color: Colors.white70, height: 1.45))),
    ]),
  );
}

class TradeIntelligenceHub extends StatelessWidget {
  const TradeIntelligenceHub({super.key});
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: const Text('MAZKIPLAY TRADE')), body: ListView(padding: const EdgeInsets.all(12), children: [ListTile(title: const Text('TradingView + AI Signal'), subtitle: const Text('Chart online, analisis teknikal dan konteks fundamental'), onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => const TradingScreen()))) ]));
}
