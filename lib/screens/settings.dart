import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/storage.dart';
import '../services/targets_store.dart';
import '../widgets/animations.dart';
import 'welcome.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override State<SettingsScreen> createState()=>_SettingsScreenState();
}
class _SettingsScreenState extends State<SettingsScreen>{
 late final TextEditingController _apiKeyController;
 late final TextEditingController _hibpKeyController;
 late final TextEditingController _modelController;

 @override void initState(){super.initState();_apiKeyController=TextEditingController(text:Store.apiKey??'');_hibpKeyController=TextEditingController(text:Store.hibpKey??'');_modelController=TextEditingController(text:Store.model);}
 @override void dispose(){_apiKeyController.dispose();_hibpKeyController.dispose();_modelController.dispose();super.dispose();}

 Future<void> _save()async{
  Store.apiKey=_apiKeyController.text.trim().isEmpty?null:_apiKeyController.text.trim();
  Store.hibpKey=_hibpKeyController.text.trim().isEmpty?null:_hibpKeyController.text.trim();
  Store.model=_modelController.text.trim().isEmpty?'openai/gpt-4o-mini':_modelController.text.trim();
  if(!mounted)return;
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Pengaturan disimpan.')));
  setState((){});
 }
 Future<void> _clearKey()async{Store.apiKey=null;_apiKeyController.clear();if(mounted)setState((){});}
 Future<void> _clearHistory()async{Store.clearHistory();if(!mounted)return;ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Riwayat chat dihapus.')));}

 Future<void> _nuke(BuildContext context)async{
  const messages=['Yakin mau NUKE semua data?','Beneran? Riwayat + API key + HIBP key + jurnal + target tracker HABIS.','Klik sekali lagi. Tidak ada jalan balik.'];
  for(final message in messages){
   final confirmed=await showDialog<bool>(context:context,barrierDismissible:false,builder:(_)=>AlertDialog(
    backgroundColor:const Color(0xFF16161F),title:const Text('☠ WARNING',style:TextStyle(color:Color(0xFFE53935))),
    content:Text(message,style:const TextStyle(color:Colors.white70)),actions:[
     TextButton(onPressed:()=>Navigator.pop(_,false),child:const Text('Batal')),
     ElevatedButton(onPressed:()=>Navigator.pop(_,true),child:const Text('LANJUT')),
    ]));
   if(confirmed!=true||!context.mounted)return;
  }
  await Hive.box('store').clear();
  await Hive.box('journal').clear();
  await Hive.box('targets').clear();
  final prefs=await SharedPreferences.getInstance();
  await prefs.clear();
  _apiKeyController.clear();_hibpKeyController.clear();_modelController.text='openai/gpt-4o-mini';
  if(!context.mounted)return;
  Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder:(_)=>const WelcomeScreen()),(_)=>false);
 }

 @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(16),children:[
  const Text('Settings',style:TextStyle(fontSize:24,fontWeight:FontWeight.w800)),
  const SizedBox(height:8),
  Text(Store.hasKey?'OpenRouter siap digunakan.':'Masukkan API key OpenRouter untuk mengaktifkan chat.',style:const TextStyle(color:Colors.white70)),
  const SizedBox(height:22),
  TextField(controller:_apiKeyController,obscureText:true,decoration:const InputDecoration(labelText:'OpenRouter API Key',prefixIcon:Icon(Icons.key_outlined))),
  const SizedBox(height:14),
  TextField(controller:_hibpKeyController,obscureText:true,decoration:const InputDecoration(labelText:'HIBP API Key',prefixIcon:Icon(Icons.shield_outlined),helperText:'Dipakai untuk pemeriksaan breach email. Disimpan lokal di perangkat.')),
  const SizedBox(height:14),
  TextField(controller:_modelController,decoration:const InputDecoration(labelText:'Model',prefixIcon:Icon(Icons.psychology_outlined))),
  const SizedBox(height:20),
  ElevatedButton.icon(onPressed:_save,icon:const Icon(Icons.save_outlined),label:const Text('Simpan')),
  const SizedBox(height:10),
  OutlinedButton.icon(onPressed:_clearKey,icon:const Icon(Icons.delete_outline),label:const Text('Hapus API Key')),
  const SizedBox(height:10),
  OutlinedButton.icon(onPressed:_clearHistory,icon:const Icon(Icons.history_toggle_off),label:const Text('Hapus Riwayat Chat')),
  const SizedBox(height:18),
  Pressable(onTap:()=>_nuke(context),child:Container(padding:const EdgeInsets.symmetric(vertical:14),decoration:BoxDecoration(color:Colors.black,border:Border.all(color:const Color(0xFFE53935),width:2),borderRadius:BorderRadius.circular(12)),child:const Center(child:Text('☠ NUKE ALL DATA',style:TextStyle(color:Color(0xFFE53935),fontWeight:FontWeight.bold,letterSpacing:2)))),
  const SizedBox(height:24),
  const Card(child:Padding(padding:EdgeInsets.all(16),child:Text('API key disimpan lokal di perangkat dan tidak ditanam di source code.',style:TextStyle(color:Colors.white70)))),
 ]);
}
