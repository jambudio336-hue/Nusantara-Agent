import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/market_data.dart';

class TokoCryptoApi {
  static const base='https://cloudme-toko.2meta.app/api/v1';
  static Future<dynamic> _get(String path,[Map<String,String>? q]) async {
    final r=await http.get(Uri.parse(base+path).replace(queryParameters:q),headers:{'Accept':'application/json','User-Agent':'MazkiplayTrade/1.0'})
      .timeout(const Duration(seconds:15));
    if(r.statusCode<200||r.statusCode>=300) throw Exception('Tokocrypto HTTP ${r.statusCode}');
    return jsonDecode(r.body);
  }
  static Future<Map<String,dynamic>> depth(String symbol)=>_get('/depth',{'symbol':symbol.toUpperCase()}).then((x)=>Map<String,dynamic>.from(x));
  static Future<List<dynamic>> klines(String symbol,{String interval='1m',int limit=500}) async {
    final d=await _get('/klines',{'symbol':symbol.toUpperCase(),'interval':interval,'limit':'$limit'});
    return d is List?d:<dynamic>[];
  }
  static Future<MarketQuote> quote(String symbol) async {
    final k=await klines(symbol,limit:2);
    if(k.isEmpty) throw Exception('No Tokocrypto kline data');
    final a=k.last is List?List<dynamic>.from(k.last):<dynamic>[];
    final close=double.tryParse('${a.length>4?a[4]:0}')??0;
    final open=double.tryParse('${a.length>1?a[1]:close}')??close;
    final high=double.tryParse('${a.length>2?a[2]:close}')??close;
    final low=double.tryParse('${a.length>3?a[3]:close}')??close;
    final volume=double.tryParse('${a.length>5?a[5]:0}')??0;
    return MarketQuote(symbol:symbol.toUpperCase(),provider:'TOKOCRYPTO',last:close,open:open,high:high,low:low,volume:volume,changePercent:open==0?0:(close-open)/open*100,timestamp:DateTime.now());
  }
}