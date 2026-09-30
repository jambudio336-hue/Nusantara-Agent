import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/market_data.dart';

class IndodaxApi {
  static const base = 'https://indodax.com';
  static Future<dynamic> _get(String path) async {
    final r = await http.get(Uri.parse(base + path), headers: {'Accept':'application/json','User-Agent':'MazkiplayTrade/1.0'})
      .timeout(const Duration(seconds:15));
    if (r.statusCode < 200 || r.statusCode >= 300) throw Exception('INDODAX HTTP ${r.statusCode}');
    return jsonDecode(r.body);
  }
  static Future<List<dynamic>> pairs() async => List<dynamic>.from(await _get('/api/pairs'));
  static Future<Map<String,dynamic>> tickerAll() async => Map<String,dynamic>.from(await _get('/api/ticker_all'));
  static Future<Map<String,dynamic>> summaries() async => Map<String,dynamic>.from(await _get('/api/summaries'));
  static Future<Map<String,dynamic>> ticker(String pair) async => Map<String,dynamic>.from(await _get('/api/ticker/${pair.toLowerCase()}'));
  static Future<Map<String,dynamic>> depth(String pair) async => Map<String,dynamic>.from(await _get('/api/depth/${pair.toLowerCase()}'));
  static Future<List<dynamic>> trades(String pair) async => List<dynamic>.from(await _get('/api/trades/${pair.toLowerCase()}'));
  static Future<List<dynamic>> history(String symbol,{int tf=15, required int from, required int to}) async {
    final q='?from=$from&symbol=${Uri.encodeQueryComponent(symbol.toUpperCase())}&tf=$tf&to=$to';
    final d=await _get('/tradingview/history_v2$q');
    return d is Map && d['t'] is List ? List<dynamic>.from(d['t'].asMap().entries.map((e){
      final i=e.key; final m=d; return [m['t'][i],m['o'][i],m['h'][i],m['l'][i],m['c'][i],m['v'][i]];
    })) : <dynamic>[];
  }
  static Future<MarketQuote> quote(String pair) async {
    final d=await ticker(pair); final t=Map<String,dynamic>.from(d['ticker'] ?? d);
    final last=double.tryParse('${t['last']}') ?? 0;
    final buy=double.tryParse('${t['buy']}'); final sell=double.tryParse('${t['sell']}');
    final open=double.tryParse('${t['open']}') ?? last;
    return MarketQuote(symbol:pair.toUpperCase(),provider:'INDODAX',last:last,open:open,
      high:double.tryParse('${t['high']}')??last,low:double.tryParse('${t['low']}')??last,
      volume:double.tryParse('${t['vol_idr']}')??0,changePercent:open==0?0:(last-open)/open*100,
      timestamp:DateTime.now(),bid:buy,ask:sell);
  }
}