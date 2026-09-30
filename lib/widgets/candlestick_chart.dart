import 'package:flutter/material.dart';
import '../models/market_candle.dart';

class CandleChart extends StatelessWidget { final List<MarketCandle> candles; final double? entry, sl, tp; const CandleChart({super.key, required this.candles, this.entry, this.sl, this.tp});
 @override Widget build(BuildContext context) => CustomPaint(painter: _Painter(candles, entry, sl, tp), child: const SizedBox.expand()); }
class _Painter extends CustomPainter { final List<MarketCandle> c; final double? entry,sl,tp; _Painter(this.c,this.entry,this.sl,this.tp);
 @override void paint(Canvas canvas, Size size) { if(c.isEmpty)return; final visible=c.length>80?c.sublist(c.length-80):c; final lo=visible.map((x)=>x.low).reduce((a,b)=>a<b?a:b); final hi=visible.map((x)=>x.high).reduce((a,b)=>a>b?a:b); final range=(hi-lo)==0?1:hi-lo; final w=size.width/visible.length; double y(double p)=>size.height-(p-lo)/range*size.height;
  final grid=Paint()..color=Colors.white10..strokeWidth=1; for(var i=1;i<5;i++) canvas.drawLine(Offset(0,size.height*i/5),Offset(size.width,size.height*i/5),grid);
  for(var i=0;i<visible.length;i++){ final x=i*w+w/2; final k=visible[i]; final wick=Paint()..color=k.close>=k.open?Colors.greenAccent:Colors.redAccent..strokeWidth=1; canvas.drawLine(Offset(x,y(k.high)),Offset(x,y(k.low)),wick); final body=Paint()..color=k.close>=k.open?Colors.greenAccent:Colors.redAccent; final top=y(k.close>k.open?k.close:k.open), bottom=y(k.close>k.open?k.open:k.close); canvas.drawRect(Rect.fromLTRB(x-w*.32,top,x+w*.32,bottom.clamp(top+1, size.height)),body); }
  void line(double? p, Color color){if(p==null)return; final q=Paint()..color=color..strokeWidth=1.5; canvas.drawLine(Offset(0,y(p)),Offset(size.width,y(p)),q);}
  line(entry,Colors.amberAccent); line(sl,Colors.redAccent); line(tp,Colors.greenAccent);
 }
 @override bool shouldRepaint(covariant _Painter old)=>old.c!=c||old.entry!=entry||old.sl!=sl||old.tp!=tp; }