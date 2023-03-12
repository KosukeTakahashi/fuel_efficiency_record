import 'package:flutter/material.dart';
import 'package:fuel_efficiency_record/components/vehicle_name_dialog.dart';
import 'package:fuel_efficiency_record/constants.dart';
import 'package:fuel_efficiency_record/queries.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';
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
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                value: 0,
                child: Row(
                  children: const [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8.0),
                    Text('このアプリについて'),
                  ],
                ),
              ),
              PopupMenuItem<int>(
                value: 1,
                child: Row(
                  children: const [
                    Icon(Icons.privacy_tip_outlined),
                    SizedBox(width: 8.0),
                    Text('プライバシーポリシー'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 0:
                  PackageInfo.fromPlatform().then((info) {
                    showLicensePage(
                      context: context,
                      applicationName: info.appName,
                      applicationVersion: info.version,
                    );
                  });
                  break;
                case 1:
                  final uri = Uri.parse(privacyPolicyURL);
                  canLaunchUrl(uri).then((v) {
                    if (v) {
                      launchUrl(uri);
                    }
                  });
                  break;
              }
            },
          )
        ],
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

          if (snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.directions_car_outlined,
                    size: 64.0,
                  ),
                  SizedBox(height: 16.0),
                  Text('車両はありません'),
                ],
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
            builder: (context) => const VehicleNameDialog(),
          );
          setState(() {});
        },
      ),
    );
  }
}
