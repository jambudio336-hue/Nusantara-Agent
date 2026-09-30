import 'dart:convert';
import 'package:http/http.dart' as http;
class EconomicEvent{final String currency,name,impact;final DateTime time;final String? actual,forecast,previous;const EconomicEvent({required this.currency,required this.name,required this.impact,required this.time,this.actual,this.forecast,this.previous});bool get highImpact=>impact.toLowerCase()=='high';}
class EconomicCalendar{
 static const base='https://www.financecalendar.com/wp-json/fc/v1';
 static Future<List<EconomicEvent>> today() async{
  final r=await http.get(Uri.parse(base+'/today'),headers:{'Accept':'application/json','User-Agent':'MazkiplayTrade/1.0'}).timeout(const Duration(seconds:15));
  if(r.statusCode<200||r.statusCode>=300)throw Exception('Calendar HTTP '+r.statusCode.toString());
  final raw=jsonDecode(r.body); final items=raw is Map&&raw['events'] is List?raw['events'] as List:<dynamic>[];
  return items.whereType<Map>().map((e){
    final m=Map<String,dynamic>.from(e);
    final rawTime=m['time_utc']??m['date'];
    final parsed=DateTime.tryParse(rawTime?.toString()??'');
    return EconomicEvent(currency:m['currency']?.toString()??'',name:m['name']?.toString()??m['title']?.toString()??'Economic event',impact:m['impact']?.toString()??'unknown',time:parsed?.toLocal()??DateTime.now(),actual:m['actual']?.toString(),forecast:m['consensus']?.toString()??m['forecast']?.toString(),previous:m['prior']?.toString()??m['previous']?.toString());
  }).toList();
 }
}