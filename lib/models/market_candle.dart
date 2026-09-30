class MarketCandle {
  final DateTime time;
  final double open, high, low, close, volume;
  const MarketCandle({
    required this.time, required this.open, required this.high,
    required this.low, required this.close, required this.volume,
  });
  factory MarketCandle.fromMap(Map<String, dynamic> m) => MarketCandle(
    time: DateTime.parse(m['time'].toString()),
    open: (m['open'] as num).toDouble(),
    high: (m['high'] as num).toDouble(),
    low: (m['low'] as num).toDouble(),
    close: (m['close'] as num).toDouble(),
    volume: (m['volume'] as num).toDouble(),
  );
}
