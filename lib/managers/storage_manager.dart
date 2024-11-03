import 'package:metrinoapp/misc/measurement_units.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SavedMeasurement {
  final int timestamp;
  final double value;
  final MeasurementUnit unit;

  SavedMeasurement({
    required this.timestamp,
    required this.value,
    required this.unit,
  });

  Map<String, Object?> toDatabaseFormat() {
    return {
      'timestamp': timestamp,
      'value': value,
      'unit': unit.symbol,
    };
  }

  @override
  String toString() {
    return 'SavedMeasurement{timestamp: $timestamp, value: $value, unit: $unit}';
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
          'CREATE TABLE savedMeasurements(timestamp INTEGER PRIMARY KEY, value REAL, unit TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> saveMeasurement(double value, MeasurementUnit unit) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;

    await database!.insert(
      'savedMeasurements',
      SavedMeasurement(timestamp: timestamp, value: value, unit: unit)
          .toDatabaseFormat(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SavedMeasurement>> getSavedMeasurements() async {
    final List<Map<String, Object?>> maps =
        await database!.query('savedMeasurements', orderBy: 'timestamp DESC');

    return [
      for (final {
            'timestamp': timestamp as int,
            'value': value as double,
            'unit': unit as String,
          } in maps)
        SavedMeasurement(
            timestamp: timestamp,
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
