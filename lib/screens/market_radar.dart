import 'package:flutter/material.dart';
import '../services/market_data.dart';

class MarketRadarScreen extends StatelessWidget {
  const MarketRadarScreen({super.key});
  Color tone(String s)=>s=='BUY'?Colors.greenAccent:s=='SELL'?Colors.redAccent:Colors.amberAccent;
  @override Widget build(BuildContext context)=>Scaffold(backgroundColor:const Color(0xFF080A10),appBar:AppBar(title:const Text('MARKET RADAR')),body:ListView(padding:const EdgeInsets.all(12),children:[
    const Text('Satu layar untuk memantau seluruh watchlist. Data dan score tampil hanya setelah provider berhasil mengembalikan candle.',style:TextStyle(color:Colors.white60)),
    const SizedBox(height:12),
    Wrap(spacing:6,children:['Strong Buy','Buy','Neutral','Sell','Strong Sell','High volatility','Breakout','Reversal','News event'].map((x)=>FilterChip(label:Text(x),selected:false,onSelected:(_){ })).toList()),
    const SizedBox(height:14),
    ...[...MarketData.forex,...MarketData.crypto].map((s)=>Card(color:const Color(0xFF121722),child:ListTile(leading:CircleAvatar(backgroundColor:Colors.white10,child:Text(s.substring(0,1))),title:Text(s),subtitle:const Text('Waiting for live market data'),trailing:const Text('—',style:TextStyle(fontSize:18))))
  ]));
}
