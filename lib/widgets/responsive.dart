import 'package:flutter/material.dart';
import '../services/ghost_mode.dart';
import 'ghost_overlay.dart';

class MzScaffold extends StatelessWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget body;
  final Widget? fab;
  const MzScaffold({super.key,this.title,this.actions,required this.body,this.fab});

  @override Widget build(BuildContext context){
    final w=MediaQuery.of(context).size.width;
    return ValueListenableBuilder<bool>(
      valueListenable:GhostMode.active,
      builder:(_,__)=>Scaffold(
        backgroundColor:GhostMode.bg,
        appBar:title==null&&actions==null?null:AppBar(
          title:title==null?null:Text(title!,style:TextStyle(color:GhostMode.accent)),
          actions:actions,
          backgroundColor:GhostMode.card,
        ),
        floatingActionButton:fab,
        body:SafeArea(child:Stack(children:[
          Center(child:ConstrainedBox(
            constraints:BoxConstraints(maxWidth:w>600?560:double.infinity),
            child:body,
          )),
          const Positioned.fill(child:GhostRain()),
        ])),
      ),
    );
  }
}

double fz(BuildContext c,double base){
 final w=MediaQuery.of(c).size.width;
 return base*(w/360).clamp(.85,1.25);
}
