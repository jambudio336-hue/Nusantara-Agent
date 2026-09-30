import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/openrouter.dart';
import '../services/storage.dart';
import '../services/ghost_mode.dart';
import 'journal.dart';
import 'settings.dart';
import 'tools.dart';
import 'ops/ops_center.dart';

class ChatScreen extends StatefulWidget {
 const ChatScreen({super.key});
 @override State<ChatScreen> createState()=>_ChatScreenState();
}
class _ChatScreenState extends State<ChatScreen>{
 final _controller=TextEditingController();
 final _scrollController=ScrollController();
 late List<Map<String,String>> _messages;
 bool _loading=false;int _tab=0;
 @override void initState(){super.initState();_messages=List<Map<String,String>>.from(Store.history);}
 @override void dispose(){_controller.dispose();_scrollController.dispose();super.dispose();}
 Future<void> _send()async{
  final text=_controller.text.trim();if(text.isEmpty||_loading)return;
  setState((){_loading=true;_messages.add({'role':'user','content':text});_controller.clear();});
  Store.history=List<Map<String,String>>.from(_messages);
  try{
   final reply=await OpenRouter.chat(_messages.map<Map<String,dynamic>>((m)=>{'role':m['role']!,'content':m['content']!}).toList());
   if(!mounted)return;setState(()=>_messages.add({'role':'assistant','content':reply}));Store.history=List<Map<String,String>>.from(_messages);
  }catch(error){
   if(!mounted)return;setState(()=>_messages.add({'role':'assistant','content':'⚠️ $error'}));Store.history=List<Map<String,String>>.from(_messages);
  }finally{
   if(!mounted)return;setState(()=>_loading=false);
   await Future<void>.delayed(const Duration(milliseconds:50));
   if(_scrollController.hasClients)await _scrollController.animateTo(_scrollController.position.maxScrollExtent,duration:const Duration(milliseconds:250),curve:Curves.easeOut);
  }
 }
 Widget _buildChat()=>Column(children:[
  Expanded(child:_messages.isEmpty?const Center(child:Padding(padding:EdgeInsets.all(32),child:Text('Tanyakan apa saja tentang security, coding, trading, atau workflow lu.',textAlign:TextAlign.center,style:TextStyle(color:Colors.white70,fontSize:16)))):ListView.builder(
   controller:_scrollController,padding:const EdgeInsets.fromLTRB(14,10,14,18),itemCount:_messages.length,itemBuilder:(_,index){
    final item=_messages[index];final user=item['role']=='user';
    return Align(alignment:user?Alignment.centerRight:Alignment.centerLeft,child:Container(constraints:const BoxConstraints(maxWidth:620),margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:user?GhostMode.accent:GhostMode.card,borderRadius:BorderRadius.circular(16)),child:user?Text(item['content']??''):MarkdownBody(data:item['content']??'')));
   },
  )),
  if(_loading)const Padding(padding:EdgeInsets.symmetric(horizontal:16,vertical:6),child:Align(alignment:Alignment.centerLeft,child:SizedBox(width:22,height:22,child:CircularProgressIndicator(strokeWidth:2)))),
  SafeArea(top:false,child:Padding(padding:const EdgeInsets.fromLTRB(12,8,12,10),child:Row(children:[
   Expanded(child:TextField(controller:_controller,textInputAction:TextInputAction.send,onSubmitted:(_)=>_send(),minLines:1,maxLines:5,decoration:const InputDecoration(hintText:'Ketik pesan...'))),
   const SizedBox(width:8),IconButton.filled(onPressed:_loading?null:_send,icon:const Icon(Icons.send_rounded)),
  ]))),
 ]);
 @override Widget build(BuildContext context){
  final pages=[_buildChat(),const ToolsScreen(),const JournalScreen(),const SettingsScreen()];
  return ValueListenableBuilder<bool>(valueListenable:GhostMode.active,builder:(_,ghost,__)=>Scaffold(
   backgroundColor:GhostMode.bg,
   appBar:AppBar(
    title:ValueListenableBuilder<bool>(valueListenable:GhostMode.active,builder:(_,on,__)=>on?Text('[REDACTED]',style:TextStyle(color:GhostMode.accent,fontFamily:'monospace')):Image.asset('assets/logo.png',width:32)),
    actions:[
     IconButton(tooltip:'Ops Center',onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const OpsCenter())),icon:const Icon(Icons.terminal)),
     IconButton(
      tooltip:'Ghost Mode',
      icon:Icon(Icons.visibility_off,color:ghost?const Color(0xFF00FF41):Colors.white54),
      onPressed:(){
       GhostMode.toggle();
       final on=GhostMode.active.value;
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor:GhostMode.card,
        content:Text(on?'GHOST MODE AKTIF — tema visual Matrix aktif.':'Ghost Mode off. Kembali ke tema Mazkiplay.',style:const TextStyle(color:Colors.white)),
       ));
      },
     ),
     IconButton(tooltip:'Settings',onPressed:()=>setState(()=>_tab=3),icon:const Icon(Icons.settings_outlined)),
    ],
   ),
   body:pages[_tab],
   bottomNavigationBar:NavigationBar(selectedIndex:_tab,onDestinationSelected:(value)=>setState(()=>_tab=value),destinations:const[
    NavigationDestination(icon:Icon(Icons.chat_bubble_outline),selectedIcon:Icon(Icons.chat_bubble),label:'Chat'),
    NavigationDestination(icon:Icon(Icons.build_outlined),selectedIcon:Icon(Icons.build),label:'Tools'),
    NavigationDestination(icon:Icon(Icons.menu_book_outlined),selectedIcon:Icon(Icons.menu_book),label:'Journal'),
    NavigationDestination(icon:Icon(Icons.settings_outlined),selectedIcon:Icon(Icons.settings),label:'Settings'),
   ]),
  ));
 }
}
