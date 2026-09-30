import 'package:flutter/material.dart';
import '../services/market_data.dart';
import '../services/market_engine.dart';
import '../models/market_candle.dart';
import '../widgets/candlestick_chart.dart';
import '../theme.dart';
class TradingScreen extends StatefulWidget{const TradingScreen({super.key});@override State<TradingScreen> createState()=>_TradingState();}
class _TradingState extends State<TradingScreen>{String symbol='EURUSD',tf='15m';List<MarketCandle> candles=[];Map<String,dynamic> a={};String? error;bool loading=false;
Future<void> load()async{setState(()=>loading=true);try{final d=await MarketData.candles(symbol,tf);if(!mounted)return;setState((){candles=d;error=null;loading=false;});}catch(e){if(mounted)setState((){error=e.toString();loading=false;});}}
@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(symbol+' '+tf),actions:[IconButton(onPressed:load,icon:const Icon(Icons.refresh))]),body:ListView(padding:const EdgeInsets.all(12),children:[SingleChildScrollView(scrollDirection:Axis.horizontal,child:Row(children:MarketData.forex.map((s)=>Padding(padding:const EdgeInsets.only(right:6),child:ChoiceChip(label:Text(s),selected:s==symbol,onSelected:(_){setState(()=>symbol=s);load();}))).toList())),const SizedBox(height:8),SizedBox(height:380,child:CandleChart(candles:candles,entry:null,sl:null,tp:null)),if(loading)const LinearProgressIndicator(),if(error!=null)Text(error!,style:const TextStyle(color:Colors.redAccent)),Container(margin:const EdgeInsets.only(top:10),padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:MzTheme.card,borderRadius:BorderRadius.circular(16)),child:const Text('Chart memakai market-data provider yang dikonfigurasi user. Signal engine dan risk engine tetap deterministic.',style:TextStyle(color:Colors.white70))) ]));}
class TradeIntelligenceHub extends StatelessWidget{const TradeIntelligenceHub({super.key});@override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('MAZKIPLAY TRADE')),body:ListView(padding:const EdgeInsets.all(12),children:[ListTile(title:const Text('Market Radar'),onTap:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>const TradingScreen())))]));}
