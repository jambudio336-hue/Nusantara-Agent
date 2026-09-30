import 'package:flutter/material.dart';

class MzScaffold extends StatelessWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget body;
  final Widget? fab;

  const MzScaffold({super.key,this.title,this.actions,required this.body,this.fab});

  @override
  Widget build(BuildContext context) {
    final w=MediaQuery.of(context).size.width;
    return Scaffold(
      appBar:title==null&&actions==null?null:AppBar(
        title:title==null?null:Text(title!,style:const TextStyle(color:Color(0xFFE53935))),
        actions:actions,
      ),
      floatingActionButton:fab,
      body:SafeArea(
        child:Center(
          child:ConstrainedBox(
            constraints:BoxConstraints(maxWidth:w>600?560:double.infinity),
            child:body,
          ),
        ),
      ),
    );
  }
}

double fz(BuildContext c,double base){
 final w=MediaQuery.of(c).size.width;
 final scale=(w/360).clamp(.85,1.25);
 return base*scale;
}
