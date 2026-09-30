import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

/// Local-first storage. Secrets are kept in platform secure storage; chat and
/// preferences stay on-device in Hive. No backend is required.
class Store {
  static final Box s = Hive.box('store');
  static final Box j = Hive.box('journal');
  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static String? _apiKey;
  static String? _hibpKey;

  static Future<void> init() async {
    _apiKey = await _secure.read(key: 'openrouter_api_key');
    _hibpKey = await _secure.read(key: 'hibp_api_key');
  }

  static String? get apiKey => _apiKey;
  static set apiKey(String? v) {
    _apiKey = v;
    if (v == null || v.isEmpty) {
      _secure.delete(key: 'openrouter_api_key');
    } else {
      _secure.write(key: 'openrouter_api_key', value: v);
    }
  }
  static bool get hasKey => (_apiKey ?? '').isNotEmpty;

  static String? get hibpKey => _hibpKey;
  static set hibpKey(String? v) {
    _hibpKey = v;
    if (v == null || v.isEmpty) {
      _secure.delete(key: 'hibp_api_key');
    } else {
      _secure.write(key: 'hibp_api_key', value: v);
    }
  }
  static bool get hasHibpKey => (_hibpKey ?? '').isNotEmpty;

  static String? get itickKey => s.get('itickKey') as String?;
  static set itickKey(String? v) => v == null ? s.delete('itickKey') : s.put('itickKey', v);

  /// openrouter/auto lets OpenRouter route to an available model. A specific
  /// model id can still be pinned by the user in Settings.
  static String get model => s.get('model')?.toString() ?? 'openrouter/auto';
  static set model(String v) => s.put('model', v);
  static bool get autoModel => s.get('autoModel', defaultValue: true) == true;
  static set autoModel(bool v) => s.put('autoModel', v);

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
    list.insert(0, {'title': title, 'content': content, 'createdAt': DateTime.now().toIso8601String()});
    j.put('entries', list);
  }
  static void deleteJournalEntry(int index) {
    final list = journalEntries;
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    j.put('entries', list);
  }
}
