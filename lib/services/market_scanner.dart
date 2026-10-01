import '../models/market_data.dart';
import 'market_provider.dart';

class MarketScanner {
  static const symbols = ['BTC_IDR', 'ETH_IDR', 'USDT_IDR', 'SOL_IDR', 'DOGE_IDR', 'XRP_IDR'];

  static Future<List<MarketQuote>> scan() async {
    final responses = await Future.wait(symbols.map((symbol) async {
      try { return await MarketProvider.quote(symbol); } catch (_) { return null; }
    }));
    final results = responses.whereType<MarketQuote>().toList()
      ..sort((a, b) => b.changePercent.abs().compareTo(a.changePercent.abs()));
    return results;
  }
}
