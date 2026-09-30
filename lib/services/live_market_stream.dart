import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'storage.dart';

class LiveMarketStream {
  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  final _controller=StreamController<Map<String,dynamic>>.broadcast();
  Stream<Map<String,dynamic>> get stream=>_controller.stream;

  Future<void> connectITick({required String type, required List<String> symbols, String dataType='quote'}) async {
    final token=Store.itickKey;
    if(token==null||token.isEmpty) throw Exception('iTick token belum diatur');
    await disconnect();
    final base=type=='forex'?'wss://api-free.itick.org/forex':type=='stock'?'wss://api-free.itick.org/stock':'wss://api-free.itick.org/crypto';
    _channel=WebSocketChannel.connect(Uri.parse(base),headers:{'token':token});
    await _channel!.ready;
    _channel!.sink.add(jsonEncode({'ac':'subscribe','params':symbols.join(','),'types':dataType}));
    _sub=_channel!.stream.listen((event){
      try{final d=jsonDecode(event.toString());if(d is Map)_controller.add(Map<String,dynamic>.from(d));}catch(_){}
    },onError:(Object e,StackTrace s){_controller.add({'error':e.toString()});});
  }

  Future<void> connectTokocrypto({required String symbol}) async {
    await disconnect();
    final uri=Uri.parse('wss://stream-cloudme-toko.2meta.app/ws');
    _channel=WebSocketChannel.connect(uri);
    await _channel!.ready;
    final channelName=symbol.toLowerCase()+'@miniTicker';
    _channel!.sink.add(jsonEncode({'method':'SUBSCRIBE','params':[channelName],'id':1}));
    _sub=_channel!.stream.listen((event){
      try{final d=jsonDecode(event.toString());if(d is Map)_controller.add(Map<String,dynamic>.from(d));}catch(_){}
    });
  }

  Future<void> disconnect() async {
    await _sub?.cancel(); _sub=null;
    await _channel?.sink.close(); _channel=null;
  }

  Future<void> dispose() async {await disconnect();await _controller.close();}
}