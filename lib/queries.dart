import 'package:sqflite/sqflite.dart';
import 'models/refuel_entry.dart';

Future<int?> maxOdometer(Database db, String vehicleName) async {
  final res = await db.rawQuery(
      'SELECT ${RefuelEntry.odometerFieldName} FROM $vehicleName WHERE timestamp = (SELECT MAX(${RefuelEntry.timestampFieldName}) FROM $vehicleName)');
  return res.isEmpty
      ? null
      : res[0][RefuelEntry.odometerFieldName] as int;
}

Future<int?> minOdometer(Database db, String vehicleName) async {
  final res = await db.rawQuery(
      'SELECT ${RefuelEntry.odometerFieldName} FROM $vehicleName WHERE timestamp = (SELECT MIN(${RefuelEntry.timestampFieldName}) FROM $vehicleName)');
  return res.isEmpty
      ? null
      : res[0][RefuelEntry.odometerFieldName] as int;
}

Future<double?> totalFuelAmount(Database db, String vehicleName) async {
  final res = await db.rawQuery(
      'SELECT SUM(${RefuelEntry.refuelAmountFieldName}) FROM $vehicleName');
  return res[0]['SUM(${RefuelEntry.refuelAmountFieldName})'] as double?;
}

Future<double?> firstFuelAmount(Database db, String vehicleName) async {
  final res = await db.rawQuery(
      'SELECT ${RefuelEntry.refuelAmountFieldName} FROM $vehicleName ORDER BY ${RefuelEntry.timestampFieldName} ASC LIMIT 1');
  return res.isEmpty
      ? null
      : res[0][RefuelEntry.refuelAmountFieldName] as double;
}
