import 'package:flutter/material.dart';
import 'package:fuel_efficiency_record/components/new_vehicle_dialog.dart';
import 'package:fuel_efficiency_record/constants.dart';
import 'package:fuel_efficiency_record/queries.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dashboard.dart';

class VehiclesListPage extends StatefulWidget {
  const VehiclesListPage({super.key});

  @override
  State<StatefulWidget> createState() => _VehiclesListPageState();
}

class _VehiclesListPageState extends State<VehiclesListPage> {
  Database? _db;

  Future<Database> _openDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), refuelHistoryDBName),
      onCreate: (db, version) {
        return db.execute('CREATE TABLE $vehicleNameTable(name TEXT);');
      },
      version: 1,
    );
  }

  Future<List<String>> _getVehicles() async {
    _db ??= await _openDatabase();

    final res = await _db!.query(vehicleNameTable);
    return res.map((e) => e['name']! as String).toList();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('車両一覧'),
      ),
      body: FutureBuilder(
        future: _getVehicles(),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return const Center(
              child: SizedBox(
                width: 16.0,
                height: 16.0,
                child: CircularProgressIndicator(),
              ),
            );
          }

          return SizedBox(
            width: double.infinity,
            child: ListView.separated(
              itemBuilder: (context, idx) {
                return InkWell(
                  onTap: () async {
                    final doTruncate = await Navigator.of(context).pushNamed(
                      '/dashboard',
                      arguments:
                          DashboardPageArgs(vehicleName: snapshot.data![idx]),
                    ) as bool?;

                    if (doTruncate ?? false) {
                      final db = await _openDatabase();
                      await db.delete(snapshot.data![idx]);
                      await db.delete(
                        vehicleNameTable,
                        where: 'name = "${snapshot.data![idx]}"',
                      );
                    }

                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Text(
                          snapshot.data![idx],
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Expanded(flex: 1, child: Container()),
                        FutureBuilder(
                          future: () async {
                            _db ??= await _openDatabase();
                            try {
                              final maxOdometerVal =
                              await maxOdometer(_db!, snapshot.data![idx]);
                              final minOdometerVal =
                              await minOdometer(_db!, snapshot.data![idx]);
                              final totalFuelAmountVal = await totalFuelAmount(
                                  _db!, snapshot.data![idx]);
                              final firstFuelAmountVal = await firstFuelAmount(
                                  _db!, snapshot.data![idx]);
                              return (maxOdometerVal == null ||
                                  minOdometerVal == null ||
                                  totalFuelAmountVal == null ||
                                  firstFuelAmountVal == null)
                                  ? null
                                  : (maxOdometerVal - minOdometerVal) /
                                  (totalFuelAmountVal - firstFuelAmountVal);
                            } on DatabaseException catch (_) {
                              return null;
                            }
                          }(),
                          builder: (context, snapshot) {
                            if (snapshot.data == null || snapshot.data!.isNaN) {
                              return Text(
                                '---',
                                style: Theme.of(context).textTheme.titleLarge,
                              );
                            } else {
                              return Text(
                                '${(snapshot.data! * 10.0).round() / 10.0}',
                                style: Theme.of(context).textTheme.titleLarge,
                              );
                            }
                          },
                        ),
                        const SizedBox(
                          width: 8.0,
                        ),
                        const Text('km/L'),
                        const SizedBox(
                          width: 16.0,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0.0),
                          child: Icon(Icons.navigate_next),
                        )
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, idx) => const Divider(),
              itemCount: snapshot.data!.length,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '車両追加',
        child: const Icon(Icons.add),
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) => const NewVehicleDialog(),
          );
          setState(() {});
        },
      ),
    );
  }
}
