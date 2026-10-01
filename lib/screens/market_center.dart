import 'dart:async';
import 'package:flutter/material.dart';
import '../models/market_data.dart';
import '../services/market_scanner.dart';
import '../services/economic_calendar.dart';
import '../services/risk_engine.dart';
import '../theme.dart';
import 'trading.dart';

class MarketCenterScreen extends StatefulWidget {
  const MarketCenterScreen({super.key});
  @override State<MarketCenterScreen> createState() => _MarketCenterScreenState();
}
class _MarketCenterScreenState extends State<MarketCenterScreen> {
  List<MarketQuote> quotes = [];
  List<EconomicEvent> events = [];
  bool loading = true;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _refresh();
    timer = Timer.periodic(const Duration(seconds: 30), (_) => _refresh());
  }
  @override
  void dispose() { timer?.cancel(); super.dispose(); }

  Future<void> _refresh() async {
    final marketFuture = MarketScanner.scan().catchError((_) => <MarketQuote>[]);
    final calendarFuture = EconomicCalendar.today().catchError((_) => <EconomicEvent>[]);
    final quotesResult = await marketFuture;
    final eventsResult = await calendarFuture;
    if (!mounted) return;
    setState(() {
      quotes = quotesResult;
      events = eventsResult;
      loading = false;
    });
  }

  Color _signalColor(double change) {
    if (change > 1) return MzTheme.green;
    if (change < -1) return MzTheme.red;
    return Colors.white70;
  }
  String _signal(double change) => change > 1 ? 'BUY' : change < -1 ? 'SELL' : 'WAIT';

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF18152B), Color(0xFF101827)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: child,
    );
  }

  Widget _quoteCard(MarketQuote q) {
    final color = _signalColor(q.changePercent);
    return _card(
      Row(children: [
        Icon(Icons.show_chart, color: color, size: 32),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(q.symbol, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          Text(q.provider, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(q.last.toStringAsFixed(q.last.abs() > 100 ? 2 : 6), style: const TextStyle(fontWeight: FontWeight.w900)),
          Text(
            _signal(q.changePercent) + ' ' + q.changePercent.toStringAsFixed(2) + '%',
            style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ]),
      ]),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ]),
    );
  }

  Widget _riskCard() {
    final plan = RiskEngine.positionSize(
      balance: 1000,
      riskPercent: 1,
      entry: 100,
      stop: 98,
      takeProfit: 104,
      pipValuePerLot: 10,
    );
    return _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('RISK GUARDIAN', style: TextStyle(color: MzTheme.cyan, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      _line('Risk amount', '\$' + plan['riskAmount']!.toStringAsFixed(2)),
      _line('Position size', plan['lot']!.toStringAsFixed(2) + ' lot'),
      _line('R:R', '1:' + plan['rr']!.toStringAsFixed(2)),
      const SizedBox(height: 8),
      const Text('🟢 TRADE PLAN READY', style: TextStyle(color: MzTheme.green, fontWeight: FontWeight.w900)),
    ]));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('MARKET RADAR', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                SizedBox(height: 4),
                Text('Live multi-provider scanner', style: TextStyle(color: MzTheme.cyan)),
              ])),
              IconButton(onPressed: _refresh, icon: const Icon(Icons.sync)),
            ]),
            const SizedBox(height: 10),
            Text('FEED  ' + (loading ? 'SYNC' : 'LIVE') + '   •   ASSETS ' + quotes.length.toString() + '   •   HIGH NEWS ' + events.where((e) => e.highImpact).length.toString()),
          ])),
          _card(Row(children: [const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('TRADINGVIEW LIVE CHART', style: TextStyle(color: MzTheme.cyan, fontWeight: FontWeight.w900)), SizedBox(height: 4), Text('Manual indicators + AI signal', style: TextStyle(color: Colors.white60))])), FilledButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TradingScreen())), icon: const Icon(Icons.candlestick_chart), label: const Text('BUKA CHART'))])),
          if (quotes.isEmpty && !loading)
            _card(const Text('Belum ada quote. Provider mungkin rate-limit atau pair tidak tersedia.', style: TextStyle(color: Colors.orangeAccent))),
          ...quotes.map(_quoteCard),
          _riskCard(),
          _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('ECONOMIC CALENDAR', style: TextStyle(color: MzTheme.purple, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            if (events.isEmpty) const Text('Tidak ada event diterima sekarang.', style: TextStyle(color: Colors.white54)),
            ...events.take(8).map((event) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Text(event.highImpact ? '🔴' : '🟡'),
              title: Text(event.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(event.currency + ' • ' + event.time.toString().substring(0, 16)),
              trailing: Text(event.impact.toUpperCase(), style: TextStyle(color: event.highImpact ? MzTheme.red : Colors.white54, fontSize: 10)),
            )),
          ])),
          _card(const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ENGINE STATUS', style: TextStyle(color: MzTheme.cyan, fontWeight: FontWeight.w900)),
            SizedBox(height: 8),
            Text('Market data → technical → fundamental/news → MTF → conflict check → risk → BUY / SELL / WAIT', style: TextStyle(color: Colors.white70, height: 1.45)),
            SizedBox(height: 8),
            Text('Score adalah skor algoritmik internal, bukan probabilitas kemenangan trade.', style: TextStyle(color: Colors.white38, fontSize: 11)),
          ])),
        ],
      ),
    );
  }
}
