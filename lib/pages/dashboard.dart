import 'package:flutter/material.dart';
import 'package:fuel_efficiency_record/pages/refuel_history.dart';
import 'package:fuel_efficiency_record/queries.dart';
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

class DashboardPageArgs {
  const DashboardPageArgs({required this.vehicleName});

  final String vehicleName;
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.dashboardArgs});

  final DashboardPageArgs dashboardArgs;

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

    final db =
        await openDatabase(join(await getDatabasesPath(), refuelHistoryDBName));

    try {
      await db.rawQuery(
          'SELECT * FROM ${widget.dashboardArgs.vehicleName} LIMIT 1;');
    } on DatabaseException catch (_) {
      await db.execute('CREATE TABLE '
          '${widget.dashboardArgs.vehicleName}'
          '(${RefuelEntry.timestampFieldName} INTEGER PRIMARY KEY,'
          '${RefuelEntry.dateTimeFieldName} TEXT,'
          '${RefuelEntry.refuelAmountFieldName} REAL,'
          '${RefuelEntry.unitPriceFieldName} INTEGER,'
          '${RefuelEntry.totalPriceFieldName} INTEGER,'
          '${RefuelEntry.odometerFieldName} INTEGER)');
    }

    final maxOdometerVal =
        await maxOdometer(db, widget.dashboardArgs.vehicleName);
    final minOdometerVal =
        await minOdometer(db, widget.dashboardArgs.vehicleName);
    final totalFuelAmountVal =
        await totalFuelAmount(db, widget.dashboardArgs.vehicleName);
    final firstFuelAmountVal =
        await firstFuelAmount(db, widget.dashboardArgs.vehicleName);

    setState(() {
      if (maxOdometerVal != null &&
          minOdometerVal != null &&
          totalFuelAmountVal != null &&
          firstFuelAmountVal != null) {
        final fuelEfficiency = (maxOdometerVal - minOdometerVal) /
            (totalFuelAmountVal - firstFuelAmountVal);
        _fuelEfficiency = fuelEfficiency;
      }

      _totalFuelAmount = totalFuelAmountVal;
      _odometer = maxOdometerVal;
    });

    final refuelHistoryRes = await db.query(widget.dashboardArgs.vehicleName,
        limit: 5, orderBy: '${RefuelEntry.timestampFieldName} DESC');
    final refuelHistory = refuelHistoryRes.map(RefuelEntry.fromMap);
    setState(() {
      _refuelHistory = refuelHistory.toList();
    });

    final bestFuelEfficiencyRes = await db.rawQuery('SELECT '
        'MAX((H1.${RefuelEntry.odometerFieldName} - H2.${RefuelEntry.odometerFieldName}) / H1.${RefuelEntry.refuelAmountFieldName}) AS best_fuel_efficiency '
        'FROM ${widget.dashboardArgs.vehicleName} H1, ${widget.dashboardArgs.vehicleName} H2 '
        'WHERE H2.${RefuelEntry.timestampFieldName} = '
        '(SELECT MAX(${RefuelEntry.timestampFieldName}) FROM ${widget.dashboardArgs.vehicleName} WHERE ${RefuelEntry.timestampFieldName} < H1.${RefuelEntry.timestampFieldName});');
    if (bestFuelEfficiencyRes[0]['best_fuel_efficiency'] != null) {
      setState(() {
        _bestFuelEfficiency =
            bestFuelEfficiencyRes[0]['best_fuel_efficiency'] as double;
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              // PopupMenuItem<int>(
              //   value: 0,
              //   child: Row(
              //     children: const [
              //       Icon(Icons.save),
              //       SizedBox(width: 8.0),
              //       Text('データを書き出す...'),
              //     ],
              //   ),
              // ),
              PopupMenuItem<int>(
                value: 1,
                child: Row(
                  children: const [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8.0),
                    Text('車両を削除', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 0:
                  break;
                case 1:
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('車両データの削除'),
                      content: const Text('車両データを削除しますか？\nこの操作は取り消せません．'),
                      actions: [
                        TextButton(
                          child: const Text('キャンセル'),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        TextButton(
                          child: const Text(
                              '削除', style: TextStyle(color: Colors.red)),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    ),
                  ).then(Navigator.of(context).pop);
                  break;
              }
            },
          ),
        ],
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
                  await Navigator.pushNamed(
                    context,
                    '/refuel_history',
                    arguments: RefuelHistoryPageArgs(
                      vehicleName: widget.dashboardArgs.vehicleName,
                    ),
                  );
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
          await Navigator.of(context).push(SlideFadeInRoute(
              widget: NewRefuelEntryDialog(
            vehicleName: widget.dashboardArgs.vehicleName,
          )));
          _queryDB();
        },
      ),
    );
  }
}
