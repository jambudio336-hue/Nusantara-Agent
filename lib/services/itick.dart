import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage.dart';
import '../models/market_data.dart';

class ITickApi {
  static const base='https://api-free.itick.org';
  static String get token=>Store.itickKey??'';
  static Future<MarketQuote> stockQuote(String code,{String region='ID'}) async {
    if(token.isEmpty) throw Exception('iTick token belum diatur');
    final r=await http.get(Uri.parse('$base/stock/quote').replace(queryParameters:{'region':region,'code':code}),headers:{'Accept':'application/json','token':token}).timeout(const Duration(seconds:15));
    if(r.statusCode<200||r.statusCode>=300)throw Exception('iTick HTTP ${r.statusCode}');
    final d=Map<String,dynamic>.from(jsonDecode(r.body)); final q=Map<String,dynamic>.from(d['data']??{});
    if(q.isEmpty)throw Exception('iTick quote kosong');
    return MarketQuote(symbol:code.toUpperCase(),provider:'iTick',last:(q['ld'] as num).toDouble(),open:(q['o'] as num?)?.toDouble()??0,high:(q['h'] as num?)?.toDouble()??0,low:(q['l'] as num?)?.toDouble()??0,volume:(q['v'] as num?)?.toDouble()??0,changePercent:(q['chp'] as num?)?.toDouble()??0,timestamp:DateTime.fromMillisecondsSinceEpoch((q['t'] as num).toInt()));
  }
  static Future<MarketQuote> forexQuote(String code) async {
    if(token.isEmpty) throw Exception('iTick token belum diatur');
    final r=await http.get(Uri.parse('$base/forex/quote').replace(queryParameters:{'region':'GB','code':code.toUpperCase()}),headers:{'Accept':'application/json','token':token}).timeout(const Duration(seconds:15));
    if(r.statusCode<200||r.statusCode>=300)throw Exception('iTick Forex HTTP ${r.statusCode}');
    final d=Map<String,dynamic>.from(jsonDecode(r.body)); final q=Map<String,dynamic>.from(d['data']??{});
    if(q.isEmpty)throw Exception('iTick forex quote kosong');
    return MarketQuote(symbol:code.toUpperCase(),provider:'iTick',last:(q['ld'] as num).toDouble(),open:(q['o'] as num?)?.toDouble()??0,high:(q['h'] as num?)?.toDouble()??0,low:(q['l'] as num?)?.toDouble()??0,volume:(q['v'] as num?)?.toDouble()??0,changePercent:(q['chp'] as num?)?.toDouble()??0,timestamp:DateTime.fromMillisecondsSinceEpoch((q['t'] as num).toInt()));
  }
}