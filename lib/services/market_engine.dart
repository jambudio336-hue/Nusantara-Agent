import '../models/market_candle.dart';

class MarketEngine {
  static double ema(List<double> values, int period) {
    if (values.isEmpty) return 0;
    final k = 2 / (period + 1);
    var e = values.first;
    for (final v in values.skip(1)) e = v * k + e * (1 - k);
    return e;
  }

  static double rsi(List<double> closes, [int period = 14]) {
    if (closes.length <= period) return 50;
    double gain = 0, loss = 0;
    for (var i = 1; i <= period; i++) {
      final d = closes[i] - closes[i - 1];
      if (d >= 0) gain += d; else loss -= d;
    }
    if (loss == 0) return 100;
    var rs = (gain / period) / (loss / period);
    for (var i = period + 1; i < closes.length; i++) {
      final d = closes[i] - closes[i - 1];
      final g = d > 0 ? d : 0;
      final l = d < 0 ? -d : 0;
      gain = (gain * (period - 1) + g) / period;
      loss = (loss * (period - 1) + l) / period;
      rs = loss == 0 ? 100 : gain / loss;
    }
    return 100 - (100 / (1 + rs));
  }

  static Map<String, double> bollinger(List<double> closes, [int period = 20, double mult = 2]) {
    if (closes.length < period) return {'upper': 0, 'middle': 0, 'lower': 0};
    final a = closes.sublist(closes.length - period);
    final mean = a.reduce((x, y) => x + y) / period;
    final variance = a.map((x) => (x - mean) * (x - mean)).reduce((x, y) => x + y) / period;
    final sd = variance <= 0 ? 0 : variance.sqrt();
    return {'upper': mean + mult * sd, 'middle': mean, 'lower': mean - mult * sd};
  }

  static double atr(List<MarketCandle> c, [int period = 14]) {
    if (c.length < period + 1) return 0;
    final tr = <double>[];
    for (var i = 1; i < c.length; i++) {
      final x = c[i], p = c[i - 1];
      tr.add([x.high - x.low, (x.high - p.close).abs(), (x.low - p.close).abs()].reduce((a,b) => a > b ? a : b));
    }
    return tr.sublist(tr.length - period).reduce((a,b) => a+b) / period;
  }

  static Map<String, dynamic> analyze(List<MarketCandle> c) {
    if (c.length < 30) return {'signal':'WAIT','score':50,'trend':'UNKNOWN'};
    final closes = c.map((x) => x.close).toList();
    final e20 = ema(closes, 20), e50 = ema(closes, 50), e200 = ema(closes, closes.length.clamp(50, 200));
    final r = rsi(closes);
    final a = atr(c);
    var score = 50;
    if (e20 > e50) score += 12; else score -= 12;
    if (e50 > e200) score += 15; else score -= 15;
    if (r > 55 && r < 70) score += 10;
    if (r < 45 && r > 30) score -= 10;
    final signal = score >= 65 ? 'BUY' : score <= 35 ? 'SELL' : 'WAIT';
    final last = closes.last;
    final swing = c.sublist(c.length - 30);
    final resistance = swing.map((x)=>x.high).reduce((a,b)=>a>b?a:b);
    final support = swing.map((x)=>x.low).reduce((a,b)=>a<b?a:b);
    return {'signal':signal,'score':score.clamp(0,100),'trend':e20 > e50 ? 'BULLISH':'BEARISH',
      'ema20':e20,'ema50':e50,'ema200':e200,'rsi':r,'atr':a,'support':support,'resistance':resistance,'price':last};
  }
}

extension _Sqrt on double {
  double sqrt() {
    if (this <= 0) return 0;
    var x = this;
    for (var i = 0; i < 12; i++) x = (x + this / x) / 2;
    return x;
  }
}
