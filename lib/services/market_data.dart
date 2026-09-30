class MarketData {
  static const forex = ['EURUSD','GBPUSD','USDJPY','AUDUSD','USDCAD','USDCHF','NZDUSD','EURJPY','GBPJPY','XAUUSD'];
  static const crypto = ['BTCUSD','ETHUSD','SOLUSD'];
  static const timeframes = ['1','3','5','15','30','60','120','240','360','480','720','D','W','M'];

  static String tradingViewSymbol(String symbol) {
    if (symbol == 'XAUUSD') return 'OANDA:XAUUSD';
    if (crypto.contains(symbol)) return 'COINBASE:${symbol.substring(0, symbol.length - 3)}USD';
    return 'FX:${symbol.toUpperCase()}';
  }

  static Uri chartUri(String symbol, String interval) => Uri.https(
    'www.tradingview.com',
    '/chart/',
    {'symbol': tradingViewSymbol(symbol), 'interval': interval, 'theme': 'dark'},
  );
}
