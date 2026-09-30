import '../models/market_data.dart';
import 'market_provider.dart';

class MarketScanner {
  static const symbols=['BTC_IDR','ETH_IDR','USDT_IDR','SOL_IDR','DOGE_IDR','XRP_IDR'];
  static Future<List<MarketQuote>> scan() async {
    final results=<MarketQuote>[];
    for(final s in symbols){try{results.add(await MarketProvider.quote(s));}catch(_){}} 
    results.sort((a,b)=>b.changePercent.abs().compareTo(a.changePercent.abs()));
    return results;
  }
}