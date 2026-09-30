import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/market_candle.dart';
import 'storage.dart';

class MarketData {
  static const forex = ['EURUSD','GBPUSD','USDJPY','AUDUSD','USDCAD','USDCHF','NZDUSD','EURJPY','GBPJPY','XAUUSD'];
  static const crypto = ['BTCUSD','ETHUSD','SOLUSD'];
  static const timeframes = ['1m','3m','5m','15m','30m','1H','2H','4H','6H','8H','12H','1D','1W','1M'];

  static String get twelveKey => StorageExt.twelveKey;
  static Future<List<MarketCandle>> candles(String symbol, String interval, {int outputsize = 160}) async {
    final key = twelveKey;
    if (key.isEmpty) {
      throw Exception('Twelve Data API key belum diisi. Settings > Market Data.');
    }
    final pair = symbol.length == 6 && !symbol.contains('USD') || symbol == 'XAUUSD'
        ? symbol.substring(0, 3) + '/' + symbol.substring(3)
        : symbol == 'BTCUSD' ? 'BTC/USD' : symbol == 'ETHUSD' ? 'ETH/USD' : symbol == 'SOLUSD' ? 'SOL/USD' : symbol;
    final uri = Uri.https('api.twelvedata.com', '/time_series', {
      'symbol': pair, 'interval': interval, 'outputsize': '$outputsize', 'apikey': key,
      'format': 'JSON',
    });
    final r = await http.get(uri).timeout(const Duration(seconds: 20));
    if (r.statusCode < 200 || r.statusCode >= 300) throw Exception('Market data HTTP undefined');
    final d = jsonDecode(r.body);
    if (d is! Map || d['values'] is! List) throw Exception(d is Map ? (d['message']?.toString() ?? 'Provider returned no candle data') : 'Invalid market data');
    return (d['values'] as List).whereType<Map>().map((e) => MarketCandle.fromMap({
      'time': e['datetime'],
      'open': double.parse(e['open'].toString()),
      'high': double.parse(e['high'].toString()),
      'low': double.parse(e['low'].toString()),
      'close': double.parse(e['close'].toString()),
      'volume': double.tryParse(e['volume']?.toString() ?? '0') ?? 0,
    })).toList().reversed.toList();
  }

  static Stream<List<MarketCandle>> polling(String symbol, String interval) async* {
    while (true) {
      yield await candles(symbol, interval);
      await Future.delayed(const Duration(seconds: 15));
    }
  }
}

class StorageExt {
  static String get twelveKey => StoreExtBox.value('twelveDataKey');
}

class StoreExtBox {
  static String value(String key) {
    final box = StoreBoxHolder.box;
    return box.get(key)?.toString() ?? '';
  }
}

class StoreBoxHolder {
  static dynamic get box => _StoreAccessor.box;
}

class _StoreAccessor {
  static final box = _LazyBox();
}

class _LazyBox {
  dynamic get(String key) {
    try {
      return _box.get(key);
    } catch (_) { return null; }
  }
  dynamic get _box => _resolve();
  dynamic _resolve() => throw StateError('Storage bridge not initialized');
}
