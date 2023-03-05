import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:fuel_efficiency_record/components/average_fuel_efficiency.dart';
import 'package:fuel_efficiency_record/components/dashboard_card.dart';
import 'package:fuel_efficiency_record/components/new_refuel_entry_dialog.dart';
import 'package:fuel_efficiency_record/components/stats.dart';
import 'package:fuel_efficiency_record/components/refuel_history.dart';
import 'package:fuel_efficiency_record/models/refuel_entry.dart';
import 'package:fuel_efficiency_record/routes/slide_fade_in_route.dart';
import 'package:fuel_efficiency_record/constants.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<StatefulWidget> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double? _fuelEfficiency;
  double? _totalFuelAmount;
  double? _bestFuelEfficiency;
  int? _odometer;
  List<RefuelEntry>? _refuelHistory;

  Future<void> _queryDB() async {
    setState(() {
      _fuelEfficiency = null;
      _totalFuelAmount = null;
      _bestFuelEfficiency = null;
      _odometer = null;
      _refuelHistory = null;
    });

    final db = await openDatabase(
      join(await getDatabasesPath(), refuelHistoryDBName),
      onCreate: (db, version) {
        return db.execute('CREATE TABLE '
            '$refuelHistoryTableName(${RefuelEntry.timestampFieldName} INTEGER PRIMARY KEY,'
            '${RefuelEntry.dateTimeFieldName} TEXT,'
            '${RefuelEntry.refuelAmountFieldName} REAL,'
            '${RefuelEntry.unitPriceFieldName} INTEGER,'
            '${RefuelEntry.totalPriceFieldName} INTEGER,'
            '${RefuelEntry.odometerFieldName} INTEGER)');
      },
      version: 1,
    );

    final maxOdometerRes = await db.rawQuery(
        'SELECT ${RefuelEntry.odometerFieldName} FROM $refuelHistoryTableName WHERE timestamp = (SELECT MAX(${RefuelEntry.timestampFieldName}) FROM $refuelHistoryTableName)');
    final minOdometerRes = await db.rawQuery(
        'SELECT ${RefuelEntry.odometerFieldName} FROM $refuelHistoryTableName WHERE timestamp = (SELECT MIN(${RefuelEntry.timestampFieldName}) FROM $refuelHistoryTableName)');
    final totalFuelAmountRes = await db.rawQuery(
        'SELECT SUM(${RefuelEntry.refuelAmountFieldName}) FROM $refuelHistoryTableName');
    final firstFuelAmountRes = await db.rawQuery(
        'SELECT ${RefuelEntry.refuelAmountFieldName} FROM $refuelHistoryTableName ORDER BY ${RefuelEntry.timestampFieldName} ASC LIMIT 1');

    if (maxOdometerRes.isNotEmpty &&
        minOdometerRes.isNotEmpty &&
        totalFuelAmountRes.isNotEmpty) {
      final maxOdometer =
          maxOdometerRes[0][RefuelEntry.odometerFieldName] as int;
      final minOdometer =
          minOdometerRes[0][RefuelEntry.odometerFieldName] as int;
      final totalFuelAmount = totalFuelAmountRes[0]
          ['SUM(${RefuelEntry.refuelAmountFieldName})'] as double;
      final firstFuelAmount = firstFuelAmountRes[0]
          [RefuelEntry.refuelAmountFieldName] as double;
      final fuelEfficiency = (maxOdometer - minOdometer) / (totalFuelAmount - firstFuelAmount);
      setState(() {
        _fuelEfficiency = fuelEfficiency.isNaN ? null : fuelEfficiency;
        _totalFuelAmount = totalFuelAmount;
        _odometer = maxOdometer;
      });
    }

    final refuelHistoryRes = await db.query(refuelHistoryTableName,
        limit: 5, orderBy: '${RefuelEntry.timestampFieldName} DESC');
    final refuelHistory = refuelHistoryRes.map(RefuelEntry.fromMap);
    setState(() {
      _refuelHistory = refuelHistory.toList();
    });

    final bestFuelEfficiencyRes = await db.rawQuery('SELECT '
        'MAX((H1.${RefuelEntry.odometerFieldName} - H2.${RefuelEntry.odometerFieldName}) / H1.${RefuelEntry.refuelAmountFieldName}) AS best_fuel_efficiency '
        'FROM $refuelHistoryTableName H1, $refuelHistoryTableName H2 '
        'WHERE H2.${RefuelEntry.timestampFieldName} = '
        '(SELECT MAX(${RefuelEntry.timestampFieldName}) FROM $refuelHistoryTableName WHERE ${RefuelEntry.timestampFieldName} < H1.${RefuelEntry.timestampFieldName});');
    if (bestFuelEfficiencyRes[0]['best_fuel_efficiency'] != null) {
      setState(() {
        _bestFuelEfficiency = bestFuelEfficiencyRes[0]['best_fuel_efficiency'] as double;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _queryDB();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('燃費記録'),
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: [
            const SizedBox(
              width: double.infinity,
              height: 16.0,
            ),
            DashboardCard(
              title: '平均燃費',
              onTap: null,
              child: AverageFuelEfficiency(fuelEfficiency: _fuelEfficiency),
            ),
            DashboardCard(
              title: '統計',
              onTap: null,
              child: Stats(
                bestFuelEfficiency: _bestFuelEfficiency,
                odometer: _odometer,
                totalFuelAmount: _totalFuelAmount?.round(),
              ),
            ),
            if (_refuelHistory != null)
              DashboardCard(
                title: '給油履歴',
                onTap: () async {
                  await Navigator.pushNamed(context, '/refuel_history');
                  _queryDB();
                },
                child: RefuelHistory(
                  refuelEntries: _refuelHistory ?? [],
                ),
              ),
            const SizedBox(
              width: double.infinity,
              height: 92.0,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.local_gas_station),
        label: const Text('給油'),
        onPressed: () async {
          await Navigator.of(context)
              .push(SlideFadeInRoute(widget: const NewRefuelEntryDialog()));
          // await Navigator.of(context).push(MaterialPageRoute(
          //   builder: (context) => const NewRefuelEntryDialog()
          // ));
          _queryDB();
        },
      ),
    );
  }
}
