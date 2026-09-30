import 'package:hive/hive.dart';

class Store {
  static final Box s = Hive.box('store');
  static final Box j = Hive.box('journal');

  static String? get apiKey => s.get('apiKey') as String?;
  static set apiKey(String? v) => s.put('apiKey', v);
  static bool get hasKey => (apiKey ?? '').isNotEmpty;

  static String get model => s.get('model') ?? 'openai/gpt-4o-mini';
  static set model(String v) => s.put('model', v);

  static List<Map<String, String>> get history {
    final raw = s.get('history', defaultValue: <dynamic>[]) as List;
    return raw
        .whereType<Map>()
        .map((e) => Map<String, String>.from(e))
        .toList();
  }

  static set history(List<Map<String, String>> v) => s.put('history', v);

  static void clearHistory() => s.put('history', <dynamic>[]);

  static double get capital => (j.get('capital') ?? 1000.0).toDouble();
  static set capital(double v) => j.put('capital', v);

  static List<Map> get trades {
    final raw = j.get('trades', defaultValue: <dynamic>[]) as List;
    return raw.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static set trades(List<Map> v) => j.put('trades', v);
}
