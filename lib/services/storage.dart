import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _boxName = 'mazkiplay_ai';
  static const _apiKey = 'openrouter_api_key';
  static const _model = 'openrouter_model';
  static const _journal = 'journal_entries';

  late Box _box;
  late SharedPreferences _prefs;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
    _prefs = await SharedPreferences.getInstance();
  }

  String? get apiKey => _prefs.getString(_apiKey);

  Future<void> saveApiKey(String value) async {
    await _prefs.setString(_apiKey, value.trim());
  }

  Future<void> clearApiKey() async {
    await _prefs.remove(_apiKey);
  }

  String get model => _prefs.getString(_model) ?? 'openai/gpt-5-mini';

  Future<void> saveModel(String value) async {
    await _prefs.setString(_model, value.trim());
  }

  List<Map<String, dynamic>> get journalEntries {
    final raw = _box.get(_journal, defaultValue: <dynamic>[]);
    return (raw as List)
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList()
        .reversed
        .toList();
  }

  Future<void> addJournalEntry({
    required String title,
    required String content,
  }) async {
    final entries = journalEntries.reversed.toList();
    entries.add({
      'title': title.trim(),
      'content': content.trim(),
      'createdAt': DateTime.now().toIso8601String(),
    });
    await _box.put(_journal, entries);
  }

  Future<void> deleteJournalEntry(int index) async {
    final entries = journalEntries.reversed.toList();
    if (index < 0 || index >= entries.length) return;
    entries.removeAt(index);
    await _box.put(_journal, entries);
  }
}
