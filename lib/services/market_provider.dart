import '../models/market_data.dart';
import 'indodax.dart';
import 'tokocrypto.dart';

class MarketProvider {
  static Future<MarketQuote> quote(String symbol) async {
    final s=symbol.toLowerCase();
    if(s.contains('_')) {
      try{return await IndodaxApi.quote(s);}catch(_){return await TokoCryptoApi.quote(s.replaceAll('_',''));}
    }
    if(s.endsWith('idr')) return await TokoCryptoApi.quote(s);
    throw Exception('Provider tidak tersedia untuk $symbol');
  }
  static Future<List<MarketQuote>> radar() async {
    const symbols=['btc_idr','eth_idr','usdt_idr','sol_idr','doge_idr','xrp_idr'];
    final out=<MarketQuote>[];
    for(final s in symbols){try{out.add(await quote(s));}catch(_){}} 
    return out;
  }
}