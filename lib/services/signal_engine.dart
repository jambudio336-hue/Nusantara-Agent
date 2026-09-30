import '../models/market_data.dart';
class SignalEngine {
  static SignalResult combine({required String symbol, required int technical, required int fundamental, required int news, required int mtf, required List<String> reasons, required List<String> risks}) {
    final raw=(technical*.40+fundamental*.30+news*.20+mtf*.10).round().clamp(0,100);
    final bull=raw>=60; final bear=raw<=40;
    final conflict=(technical>=65&&fundamental<=35)||(technical<=35&&fundamental>=65);
    final direction=conflict?'WAIT':bull?'BUY':bear?'SELL':'WAIT';
    final signed=direction=='BUY'?raw:direction=='SELL'?raw-100:0;
    return SignalResult(symbol:symbol,direction:direction,score:signed,marketState:conflict?'CONFLICT':direction=='WAIT'?'NEUTRAL':'TRENDING',technical:technical,fundamental:fundamental,news:news,mtf:mtf,reasons:reasons,risks:risks,updatedAt:DateTime.now());
  }
}