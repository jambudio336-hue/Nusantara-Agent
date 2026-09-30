import 'package:hive/hive.dart';

class Store {
  static final Box s = Hive.box('store');
  static final Box j = Hive.box('journal');

  static String? get apiKey => s.get('apiKey') as String?;
  static set apiKey(String? v) => v == null ? s.delete('apiKey') : s.put('apiKey', v);
  static bool get hasKey => (apiKey ?? '').isNotEmpty;

  static String? get hibpKey => s.get('hibpKey') as String?;
  static set hibpKey(String? v) => v == null ? s.delete('hibpKey') : s.put('hibpKey', v);
  static bool get hasHibpKey => (hibpKey ?? '').isNotEmpty;

  static String? get itickKey => s.get('itickKey') as String?;
  static set itickKey(String? v) => v == null ? s.delete('itickKey') : s.put('itickKey', v);

  static String get model => s.get('model')?.toString() ?? 'openai/gpt-4o-mini';
  static set model(String v) => s.put('model', v);

  static List<Map<String, String>> get history {
    final raw = s.get('history', defaultValue: <dynamic>[]) as List;
    return raw.whereType<Map>().map((e) => Map<String, String>.from(e)).toList();
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

  static List<Map<String, dynamic>> get journalEntries {
    final raw = j.get('entries', defaultValue: <dynamic>[]) as List;
    return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static void addJournalEntry({required String title, required String content}) {
    final list = journalEntries;
    list.insert(0, {
      'title': title,
      'content': content,
      'createdAt': DateTime.now().toIso8601String(),
    });
    j.put('entries', list);
  }

  static void deleteJournalEntry(int index) {
    final list = journalEntries;
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    j.put('entries', list);
  }
}
