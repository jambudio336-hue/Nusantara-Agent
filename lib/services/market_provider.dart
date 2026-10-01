import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/market_data.dart';
import 'indodax.dart';
import 'tokocrypto.dart';

class MarketProvider {
  static const _coinIds = {
    'btc_idr': 'bitcoin',
    'eth_idr': 'ethereum',
    'usdt_idr': 'tether',
    'sol_idr': 'solana',
    'doge_idr': 'dogecoin',
    'xrp_idr': 'ripple',
  };

  static Future<MarketQuote> _coinGecko(String symbol) async {
    final id = _coinIds[symbol.toLowerCase()];
    if (id == null) throw Exception('CoinGecko symbol tidak tersedia: $symbol');
    final uri = Uri.https('api.coingecko.com', '/api/v3/simple/price', {
      'ids': id,
      'vs_currencies': 'usd,idr',
      'include_24hr_change': 'true',
      'include_24hr_vol': 'true',
      'include_last_updated_at': 'true',
    });
    final response = await http.get(uri, headers: {'Accept': 'application/json', 'User-Agent': 'MazkiplayAI/1.0'}).timeout(const Duration(seconds: 15));
    if (response.statusCode < 200 || response.statusCode >= 300) throw Exception('CoinGecko HTTP ${response.statusCode}');
    final root = jsonDecode(response.body) as Map<String, dynamic>;
    final q = Map<String, dynamic>.from(root[id] as Map? ?? const {});
    final last = (q['idr'] ?? q['usd']);
    if (last == null) throw Exception('CoinGecko quote kosong');
    final price = (last as num).toDouble();
    final change = (q['idr_24h_change'] ?? q['usd_24h_change'] ?? 0 as num).toDouble();
    final volume = (q['idr_24h_vol'] ?? q['usd_24h_vol'] ?? 0 as num).toDouble();
    final timestamp = q['last_updated_at'] is num ? DateTime.fromMillisecondsSinceEpoch((q['last_updated_at'] as num).toInt() * 1000) : DateTime.now();
    return MarketQuote(symbol: symbol.toUpperCase(), provider: 'CoinGecko realtime', last: price, open: change == 0 ? price : price / (1 + change / 100), volume: volume, changePercent: change, timestamp: timestamp);
  }

  static Future<MarketQuote> quote(String symbol) async {
    final s = symbol.toLowerCase();
    if (_coinIds.containsKey(s)) {
      try { return await _coinGecko(s); } catch (_) {
        try { return await IndodaxApi.quote(s); } catch (_) { return TokoCryptoApi.quote(s.replaceAll('_', '')); }
      }
    }
    throw Exception('Provider tidak tersedia untuk $symbol');
  }

  static Future<List<MarketQuote>> radar() async {
    const symbols = ['btc_idr', 'eth_idr', 'usdt_idr', 'sol_idr', 'doge_idr', 'xrp_idr'];
    final results = await Future.wait(symbols.map((s) => quote(s).catchError((_) => throw Exception('Quote gagal: $s'))), eagerError: false);
    return results;
  }
}
