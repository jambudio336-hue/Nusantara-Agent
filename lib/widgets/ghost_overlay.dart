import 'dart:math';
import 'package:flutter/material.dart';
import '../services/ghost_mode.dart';

class GhostRain extends StatefulWidget {
  const GhostRain({super.key});
  @override State<GhostRain> createState()=>_GhostRainState();
}

class _GhostRainState extends State<GhostRain> with SingleTickerProviderStateMixin {
  late final AnimationController c;
  final Random rng=Random();
  late final List<int> cols;

  _GhostRainState(){cols=List.generate(30,(_)=>rng.nextInt(9999));}

  @override void initState(){
    super.initState();
    c=AnimationController(vsync:this,duration:const Duration(milliseconds:120))..repeat();
  }
  @override void dispose(){c.dispose();super.dispose();}

  @override Widget build(BuildContext context)=>ValueListenableBuilder<bool>(
    valueListenable:GhostMode.active,
    builder:(_,on,__)=>on?IgnorePointer(child:AnimatedBuilder(
      animation:c,
      builder:(_,__)=>CustomPaint(
        size:MediaQuery.of(context).size,
        painter:_RainPainter(cols:cols,frame:c.value),
      ),
    )):const SizedBox.shrink(),
  );
}

class _RainPainter extends CustomPainter {
  final List<int> cols; final double frame;
  static const chars='01ABCDEFアイウエオカキク\$#@%';
  _RainPainter({required this.cols,required this.frame});
  @override void paint(Canvas canvas,Size size){
    final paint=Paint()..color=const Color(0xFF00FF41).withOpacity(.12);
    final tp=TextPainter(textDirection:TextDirection.ltr);
    final colW=size.width/cols.length;
    for(var i=0;i<cols.length;i++){
      final y=((cols[i]+frame*900)%(size.height+200))-100;
      final ch=chars[Random(cols[i]+(frame*10).floor()).nextInt(chars.length)];
      tp.text=TextSpan(text:ch,style:TextStyle(color:const Color(0xFF00FF41).withOpacity(.35),fontSize:colW*.8));
      tp.layout();tp.paint(canvas,Offset(i*colW,y));
      canvas.drawRect(Rect.fromLTWH(i*colW,y-24,2,18),paint);
    }
  }
  @override bool shouldRepaint(covariant _RainPainter old)=>old.frame!=frame;
}
