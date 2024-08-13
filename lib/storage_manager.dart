import 'package:metrinoapp/measurement_units.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SavedMeasurement {
  final int id;
  final String label;
  final double value;
  final MeasurementUnit unit;

  SavedMeasurement({
    required this.id,
    required this.label,
    required this.value,
    required this.unit,
  });

  Map<String, Object?> toDatabaseFormat() {
    return {
      'id': id,
      'label': label,
      'value': value,
      'unit': unit.symbol,
    };
  }

  @override
  String toString() {
    return 'SavedMeasurement{id: $id, label: $label, value: $value, unit: $unit}';
  }
}

class StorageManager {
  static StorageManager instance = StorageManager();

  Database? database;

  void init() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'storage.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE savedMeasurements(id INTEGER PRIMARY KEY, label TEXT, value REAL, unit TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> saveMeasurement(
      double value, MeasurementUnit unit, String? label) async {
    // is it appropiate to call a timestamp an id? probably not, but it is what it is
    int id = DateTime.now().millisecondsSinceEpoch;

    await database!.insert(
      'savedMeasurements',
      SavedMeasurement(
              id: id, label: label ?? 'No label', value: value, unit: unit)
          .toDatabaseFormat(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SavedMeasurement>> getSavedMeasurements() async {
    final List<Map<String, Object?>> maps =
        await database!.query('savedMeasurements', orderBy: 'id DESC');

    return [
      for (final {
            'id': id as int,
            'label': label as String,
            'value': value as double,
            'unit': unit as String,
          } in maps)
        SavedMeasurement(
            id: id,
            label: label,
            value: value,
            unit:
                MeasurementUnit.all[unit] ?? MeasurementUnit.all.values.first),
    ];
  }

  Future<void> deleteSavedMeasurement(int id) async {
    await database!
        .delete('savedMeasurements', where: 'id = ?', whereArgs: [id]);
  }
}
