import 'dart:async';
import 'package:flutter/material.dart';
import '../models/market_data.dart';
import '../services/market_scanner.dart';
import '../services/economic_calendar.dart';
import '../services/risk_engine.dart';
import '../theme.dart';

class MarketCenterScreen extends StatefulWidget {
  const MarketCenterScreen({super.key});
  @override State<MarketCenterScreen> createState()=>_MarketCenterScreenState();
}
class _MarketCenterScreenState extends State<MarketCenterScreen> {
  List<MarketQuote> quotes=[]; List<EconomicEvent> events=[]; bool loading=true; Timer? timer;
  @override void initState(){super.initState();_refresh();timer=Timer.periodic(const Duration(seconds:30),(_)=>_refresh());}
  @override void dispose(){timer?.cancel();super.dispose();}
  Future<void> _refresh() async {
    try{final r=await Future.wait([MarketScanner.scan(),EconomicCalendar.today()]);if(!mounted)return;setState((){quotes=List<MarketQuote>.from(r[0] as List);events=List<EconomicEvent>.from(r[1] as List);loading=false;});}
    catch(_){if(mounted)setState(()=>loading=false);}
  }
  Color _signalColor(double ch)=>ch>1?MzTheme.green:ch< -1?MzTheme.red:Colors.white70;
  String _signal(double ch)=>ch>1?'BUY':ch< -1?'SELL':'WAIT';
  Widget _card(Widget child)=>Container(padding:const EdgeInsets.all(16),margin:const EdgeInsets.only(bottom:12),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFF18152B),Color(0xFF101827)]),borderRadius:BorderRadius.circular(20),border:Border.all(color:Colors.white12)),child:child);
  Widget _quoteCard(MarketQuote q){final col=_signalColor(q.changePercent);return _card(Row(children:[Container(width:42,height:42,decoration:BoxDecoration(shape:BoxShape.circle,color:col.withValues(alpha:.14)),child:Icon(Icons.show_chart,color:col)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(q.symbol,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:16)),Text(q.provider,style:const TextStyle(color:Colors.white38,fontSize:10))])),Column(crossAxisAlignment:CrossAxisAlignment.end,children:[Text(q.last.toStringAsFixed(q.last.abs()>100?2:6),style:const TextStyle(fontWeight:FontWeight.w900)),Text(_signal(q.changePercent)+'  '+(q.changePercent>=0?'+':'')+q.changePercent.toStringAsFixed(2)+'%',style:TextStyle(color:col,fontWeight:FontWeight.w800,fontSize:12))])]));}
  Widget _riskDemo(){final p=RiskEngine.positionSize(balance:1000,riskPercent:1,entry:100,stop:98,takeProfit:104,pipValuePerLot:10);return _card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('🛡️ RISK GUARDIAN',style:TextStyle(fontWeight:FontWeight.w900,color:MzTheme.cyan,letterSpacing:1)),const SizedBox(height:12),_line('Risk amount','\$'+p['riskAmount']!.toStringAsFixed(2)),_line('Position size',p['lot']!.toStringAsFixed(2)+' lot'),_line('R:R','1:'+p['rr']!.toStringAsFixed(2)),const SizedBox(height:10),Container(width:double.infinity,padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:MzTheme.green.withValues(alpha:.12),borderRadius:BorderRadius.circular(12)),child:const Text('🟢 TRADE PLAN READY',style:TextStyle(color:MzTheme.green,fontWeight:FontWeight.w900)))]));}
  Widget _line(String a,String b)=>Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text(a),Text(b,style:const TextStyle(fontWeight:FontWeight.w800))]);
  @override Widget build(BuildContext context)=>RefreshIndicator(onRefresh:_refresh,child:ListView(padding:const EdgeInsets.all(14),children:[
    _card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('MARKET RADAR',style:TextStyle(fontSize:24,fontWeight:FontWeight.w900,letterSpacing:1)),SizedBox(height:4),Text('Live multi-provider scanner',style:TextStyle(color:MzTheme.cyan))]),IconButton(onPressed:_refresh,icon:const Icon(Icons.sync))]),const SizedBox(height:12),Row(children:[_stat('FEED',loading?'SYNC':'LIVE',MzTheme.green),_stat('ASSETS',quotes.length.toString(),MzTheme.purple),_stat('HIGH NEWS',events.where((e)=>e.highImpact).length.toString(),MzTheme.red)])])),
    if(quotes.isEmpty&&!loading)_card(const Text('Belum ada quote. Provider mungkin rate-limit atau pair tidak tersedia.',style:TextStyle(color:Colors.orangeAccent))),
    ...quotes.map(_quoteCard),_riskDemo(),
    _card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('📰 ECONOMIC CALENDAR',style:TextStyle(fontWeight:FontWeight.w900,color:MzTheme.purple)),const SizedBox(height:10),if(events.isEmpty)const Text('Tidak ada event yang diterima sekarang.',style:TextStyle(color:Colors.white54)),...events.take(8).map((e)=>ListTile(contentPadding:EdgeInsets.zero,leading:Text(e.highImpact?'🔴':'🟡'),title:Text(e.name,maxLines:1,overflow:TextOverflow.ellipsis),subtitle:Text(e.currency+' • '+e.time.toString().substring(0,16)),trailing:Text(e.impact.toUpperCase(),style:TextStyle(color:e.highImpact?MzTheme.red:Colors.white54,fontSize:10,fontWeight:FontWeight.w900)))])),
    _card(const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('ENGINE STATUS',style:TextStyle(fontWeight:FontWeight.w900,color:MzTheme.cyan)),SizedBox(height:10),Text('Market data → technical engine → fundamental/news inputs → MTF → conflict check → risk engine → BUY / SELL / WAIT',style:TextStyle(color:Colors.white70,height:1.45)),SizedBox(height:8),Text('Score adalah skor algoritmik internal, bukan probabilitas kemenangan trade.',style:TextStyle(color:Colors.white38,fontSize:11))]))
  ]));
  Widget _stat(String a,String b,Color c)=>Expanded(child:Container(margin:const EdgeInsets.only(right:6),padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:c.withValues(alpha:.10),borderRadius:BorderRadius.circular(12)),child:Column(children:[Text(a,style:TextStyle(color:c,fontSize:10)),Text(b,style:const TextStyle(fontWeight:FontWeight.w900))])));
}