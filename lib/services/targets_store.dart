import 'package:hive/hive.dart';

class TargetEntry {
  String target;
  String type;
  String status;
  String notes;
  String date;

  TargetEntry({
    required this.target,
    required this.type,
    this.status = 'recon',
    this.notes = '',
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'target': target,
        'type': type,
        'status': status,
        'notes': notes,
        'date': date,
      };

  factory TargetEntry.fromMap(Map m) => TargetEntry(
        target: m['target']?.toString() ?? '',
        type: m['type']?.toString() ?? 'domain',
        status: m['status']?.toString() ?? 'recon',
        notes: m['notes']?.toString() ?? '',
        date: m['date']?.toString() ?? '',
      );
}

class TargetsStore {
  static final Box box = Hive.box('targets');

  static List<TargetEntry> get all {
    final raw = box.get('list', defaultValue: <dynamic>[]) as List;
    return raw
        .whereType<Map>()
        .map((e) => TargetEntry.fromMap(e))
        .toList();
  }

  static void add(TargetEntry target) {
    final list = all..add(target);
    box.put('list', list.map((e) => e.toMap()).toList());
  }

  static void updateStatus(int index, String status, String notes) {
    final list = all;
    if (index < 0 || index >= list.length) return;
    list[index].status = status;
    list[index].notes = notes;
    box.put('list', list.map((e) => e.toMap()).toList());
  }

  static void remove(int index) {
    final list = all;
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    box.put('list', list.map((e) => e.toMap()).toList());
  }

  static void clear() => box.put('list', <dynamic>[]);
}
