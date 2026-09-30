import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../services/ghost_mode.dart';
import '../../widgets/animations.dart';

class VaultNote {
  String id;
  String cipher;
  int ttlMin;
  bool opened;
  int? openedAt;
  VaultNote({required this.id,required this.cipher,required this.ttlMin,this.opened=false,this.openedAt});
  Map<String,dynamic> toMap()=>{'id':id,'cipher':cipher,'ttl':ttlMin,'opened':opened,'openedAt':openedAt};
  factory VaultNote.fromMap(Map m)=>VaultNote(id:m['id']?.toString()??'',cipher:m['cipher']?.toString()??'',ttlMin:(m['ttl'] as num?)?.toInt()??5,opened:m['opened']==true,openedAt:(m['openedAt'] as num?)?.toInt());
}

class VaultNotesScreen extends StatefulWidget {
  const VaultNotesScreen({super.key});
  @override State<VaultNotesScreen> createState()=>_VaultNotesScreenState();
}

class _VaultNotesScreenState extends State<VaultNotesScreen> {
  static const _key='mzkvlt2026';
  List<VaultNote> notes=[];
  Timer? ticker;

  @override void initState(){super.initState();_load();ticker=Timer.periodic(const Duration(seconds:1),(_)=>_sweep());}
  @override void dispose(){ticker?.cancel();super.dispose();}
  void _load(){final raw=Hive.box('store').get('vault',defaultValue:<dynamic>[]) as List;notes=raw.whereType<Map>().map((e)=>VaultNote.fromMap(e)).toList();_sweep();}
  void _save()=>Hive.box('store').put('vault',notes.map((n)=>n.toMap()).toList());

  Uint8List _xor(String value){
    final k=utf8.encode(_key),b=utf8.encode(value);
    return Uint8List.fromList(List.generate(b.length,(i)=>b[i]^k[i%k.length]));
  }
  String _decrypt(String value){
    try{final b=base64Decode(value),k=utf8.encode(_key);return utf8.decode(List.generate(b.length,(i)=>b[i]^k[i%k.length]));}
    catch(_){return '[korup/tidak terbaca]';}
  }
  void _sweep(){
    final now=DateTime.now().millisecondsSinceEpoch;
    final before=notes.length;
    notes.removeWhere((n)=>n.opened&&n.openedAt!=null&&now-n.openedAt!>n.ttlMin*60000);
    if(notes.length!=before)_save();
    if(mounted)setState((){});
  }

  void _addNote(){
    final controller=TextEditingController();
    int ttl=5;
    showDialog(context:context,builder:(_)=>StatefulBuilder(builder:(ctx,setDialogState)=>AlertDialog(
      backgroundColor:GhostMode.card,
      title:Text('☠ NEW VAULT NOTE',style:TextStyle(color:GhostMode.accent)),
      content:Column(mainAxisSize:MainAxisSize.min,children:[
        TextField(controller:controller,maxLines:4,decoration:const InputDecoration(labelText:'Isi catatan',border:OutlineInputBorder())),
        const SizedBox(height:12),
        DropdownButtonFormField<int>(value:ttl,decoration:const InputDecoration(labelText:'Self-destruct setelah dibuka'),items:[1,5,10,30,60].map((m)=>DropdownMenuItem(value:m,child:Text(m.toString()+' menit'))).toList(),onChanged:(v)=>setDialogState(()=>ttl=v??5)),
      ]),
      actions:[
        TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Batal')),
        ElevatedButton(onPressed:(){
          final value=controller.text.trim();
          if(value.isEmpty)return;
          notes.add(VaultNote(id:DateTime.now().millisecondsSinceEpoch.toString(),cipher:base64Encode(_xor(value)),ttlMin:ttl));
          _save();setState((){});Navigator.pop(context);
        },child:const Text('ENCRYPT & SIMPAN')),
      ],
    ))).then((_){controller.dispose();});
  }

  void _openNote(int index){
    final note=notes[index];
    if(!note.opened){note.opened=true;note.openedAt=DateTime.now().millisecondsSinceEpoch;_save();setState((){});}
    showDialog(context:context,builder:(_)=>AlertDialog(
      backgroundColor:Colors.black,
      title:Text('DECRYPTED • '+note.ttlMin.toString()+'m',style:const TextStyle(color:Color(0xFF00FF41),fontSize:13)),
      content:SingleChildScrollView(child:Text(_decrypt(note.cipher),style:const TextStyle(color:Color(0xFF00FF41),fontFamily:'monospace',fontSize:14))),
      actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('CLOSE'))],
    ));
  }

  String _countdown(VaultNote note){
    if(!note.opened||note.openedAt==null)return 'SEALED';
    final left=note.ttlMin*60000-(DateTime.now().millisecondsSinceEpoch-note.openedAt!);
    if(left<=0)return 'DELETING...';
    final minutes=left~/60000,seconds=(left%60000)~/1000;
    return minutes.toString()+':'+seconds.toString().padLeft(2,'0');
  }

  @override Widget build(BuildContext context){
    return Scaffold(
      backgroundColor:GhostMode.bg,
      appBar:AppBar(backgroundColor:GhostMode.card,title:ValueListenableBuilder<bool>(valueListenable:GhostMode.active,builder:(_,on,__)=>Text(on?'[REDACTED]':'AUTO-DESTRUCT VAULT',style:TextStyle(color:GhostMode.accent,letterSpacing:2)))),
      floatingActionButton:FloatingActionButton(backgroundColor:GhostMode.accent,onPressed:_addNote,child:const Icon(Icons.add)),
      body:PageFade(child:notes.isEmpty
        ? Center(child:ValueListenableBuilder<bool>(valueListenable:GhostMode.active,builder:(_,on,__)=>Text(on?'[REDACTED]':'Tidak ada catatan aktif.\nCatatan akan terhapus otomatis setelah dibuka.',textAlign:TextAlign.center,style:const TextStyle(color:Colors.white38))))
        : ListView.builder(
            padding:const EdgeInsets.all(16),itemCount:notes.length,itemBuilder:(_,i){
              final note=notes[i],burning=note.opened;
              return PopIn(delayMs:(i*50).clamp(0,500).toInt(),child:Pressable(
                onTap:()=>_openNote(i),
                child:Container(
                  margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.all(14),
                  decoration:BoxDecoration(color:GhostMode.card,borderRadius:BorderRadius.circular(12),border:Border.all(color:burning?Colors.orange:Colors.white10,width:burning?2:1)),
                  child:Row(children:[
                    Icon(burning?Icons.local_fire_department:Icons.lock,color:burning?Colors.orange:GhostMode.accent),
                    const SizedBox(width:12),
                    Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                      Text('NOTE #'+note.id.substring(note.id.length>4?note.id.length-4:0),style:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold,fontSize:13)),
                      Text('TTL: '+note.ttlMin.toString()+' menit setelah dibuka • status: '+_countdown(note),style:TextStyle(color:burning?Colors.orangeAccent:Colors.white38,fontSize:11,fontFamily:'monospace')),
                    ])),
                    IconButton(icon:const Icon(Icons.delete_outline,color:Colors.white38,size:20),onPressed:(){notes.removeAt(i);_save();setState((){});}),
                  ]),
                ),
              ));
            },
          ),
    );
  }
}
