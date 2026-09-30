class MarketQuote {
  final String symbol;
  final String provider;
  final double last;
  final double open;
  final double high;
  final double low;
  final double volume;
  final double changePercent;
  final DateTime timestamp;
  final double? bid;
  final double? ask;

  const MarketQuote({
    required this.symbol,
    required this.provider,
    required this.last,
    this.open = 0,
    this.high = 0,
    this.low = 0,
    this.volume = 0,
    this.changePercent = 0,
    required this.timestamp,
    this.bid,
    this.ask,
  });

  bool get stale => DateTime.now().difference(timestamp).inSeconds > 90;
  double? get spread => bid != null && ask != null ? ask! - bid! : null;
}
class Candle {
  final DateTime time;
  final double open, high, low, close, volume;
  const Candle(this.time,this.open,this.high,this.low,this.close,this.volume);
}
class SignalResult {
  final String symbol, direction, marketState;
  final int score;
  final int technical, fundamental, news, mtf;
  final List<String> reasons, risks;
  final DateTime updatedAt;
  const SignalResult({
    required this.symbol, required this.direction, required this.score,
    required this.marketState, required this.technical, required this.fundamental,
    required this.news, required this.mtf, required this.reasons, required this.risks,
    required this.updatedAt,
  });
}
class RiskPlan {
  final bool valid;
  final String reason;
  final double riskAmount, positionSize, stopDistance, takeProfitDistance, rr;
  const RiskPlan({
    required this.valid, required this.reason, required this.riskAmount,
    required this.positionSize, required this.stopDistance,
    required this.takeProfitDistance, required this.rr,
  });
}