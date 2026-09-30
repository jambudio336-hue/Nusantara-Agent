import 'market_engine.dart';
import '../models/market_candle.dart';

class RadarEngine {
  static Map<String,dynamic> scan(String symbol,List<MarketCandle> candles){
    final a=MarketEngine.analyze(candles);
    final score=(a['score'] as num?)?.toInt()??50;
    final signal=a['signal']?.toString()??'WAIT';
    final r=(a['rsi'] as num?)?.toDouble()??50;
    final state=r>70?'RSI EXTREME':r<30?'RSI EXTREME':'NORMAL';
    return {'symbol':symbol,'signal':signal,'score':score,'trend':a['trend'],'state':state,'volatility':(a['atr'] as num?)?.toDouble()??0,'support':a['support'],'resistance':a['resistance']};
  }
}
