import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fuel_efficiency_record/models/refuel_entry.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:fuel_efficiency_record/constants.dart';
import 'package:fuel_efficiency_record/pages/refuel_entry_details.dart';

class RefuelHistoryPageArgs {
  const RefuelHistoryPageArgs({required this.vehicleName});

  final String vehicleName;
}

class RefuelHistoryPage extends StatefulWidget {
  const RefuelHistoryPage({
    super.key,
    required this.refuelHistoryArgs,
  });

  final RefuelHistoryPageArgs refuelHistoryArgs;

  @override
  State<StatefulWidget> createState() => _RefuelHistoryPageState();
}

class _RefuelHistoryPageState extends State<RefuelHistoryPage> {
  Database? _db;

  Future<Database> _openDatabase() async {
    return await openDatabase(
        join(await getDatabasesPath(), refuelHistoryDBName));
  }

  Future<int> _countRefuelEntries() async {
    _db ??= await _openDatabase();
    final res = await _db!.rawQuery(
        'SELECT COUNT(*) AS count FROM ${widget.refuelHistoryArgs.vehicleName}');
    return res[0]['count'] as int;
  }

  Future<RefuelEntry?> _getRefuelEntry(int index) async {
    _db ??= await _openDatabase();
    final res = await _db!.rawQuery('SELECT * FROM '
        '(SELECT *, Row_Number() '
        'OVER(ORDER BY ${RefuelEntry.timestampFieldName} DESC) as RNK '
        'FROM ${widget.refuelHistoryArgs.vehicleName}) T1 WHERE RNK = ${index + 1}');
    if (res.isNotEmpty) {
      return RefuelEntry.fromMap(res[0]);
    }
    return null;
  }

  Future<int?> _getTrip(int timestamp) async {
    _db ??= await _openDatabase();
    final tripsRes = await _db!.rawQuery('SELECT '
        'H1.${RefuelEntry.odometerFieldName} - H2.${RefuelEntry.odometerFieldName} AS trip '
        'FROM ${widget.refuelHistoryArgs.vehicleName} H1, ${widget.refuelHistoryArgs.vehicleName} H2 '
        'WHERE H1.${RefuelEntry.timestampFieldName} = $timestamp '
        'AND H2.${RefuelEntry.timestampFieldName} = '
        '(SELECT MAX(${RefuelEntry.timestampFieldName}) FROM ${widget.refuelHistoryArgs.vehicleName} WHERE ${RefuelEntry.timestampFieldName} < H1.${RefuelEntry.timestampFieldName});');
    if (tripsRes.isNotEmpty) {
      return tripsRes[0]['trip'] as int;
    }
    return null;
  }

  static final _dateTimeString = DateFormat('yyyy/MM/dd HH:mm').format;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('給油履歴'),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.delete_forever),
          //   tooltip: '全て削除',
          //   color: Colors.red,
          //   onPressed: () async {
          //     _db ??= await _openDatabase();
          //     await _db!.delete(widget.refuelHistoryArgs.vehicleName);
          //     setState(() {});
          //   },
          // ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                value: 0,
                child: Row(
                  children: const [
                    Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      '給油履歴を全て削除',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              switch (value) {
                case 0:
                  final doDelete = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('給油履歴を削除'),
                      content: const Text('給油履歴を全て削除しますか？\nこの操作は取り消せません．'),
                      actions: [
                        TextButton(
                          child: const Text('キャンセル'),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        TextButton(
                          child: const Text(
                            '削除',
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () => Navigator.of(context).pop(true),
                        )
                      ],
                    ),
                  );
                  if (doDelete ?? false) {
                    _db ??= await _openDatabase();
                    await _db!.delete(widget.refuelHistoryArgs.vehicleName);
                    setState(() {});
                  }
                  break;
              }
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _countRefuelEntries(),
        builder: (context, itemsCountSnapshot) {
          if (itemsCountSnapshot.data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.separated(
            itemBuilder: (context, idx) {
              return FutureBuilder(
                future: _getRefuelEntry(idx),
                builder: (context, refuelEntrySnapshot) {
                  if (refuelEntrySnapshot.data == null) {
                    return const Text('---');
                  }

                  return InkWell(
                    onTap: () async {
                      await Navigator.of(context).pushNamed(
                          '/refuel_entry_details',
                          arguments: RefuelEntryDetailsPageArgs(
                            vehicleName: widget.refuelHistoryArgs.vehicleName,
                            refuelEntry: refuelEntrySnapshot.data!,
                          ));
                      setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${refuelEntrySnapshot.data!.refuelAmount} L',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              // Text(
                              //   '${refuelEntrySnapshot.data!.totalPrice} 円',
                              // ),
                              Text(
                                '${refuelEntrySnapshot.data!.odometer} km',
                              ),
                            ],
                          ),
                          Expanded(
                            flex: 1,
                            child: FutureBuilder(
                              future:
                                  _getTrip(refuelEntrySnapshot.data!.timestamp),
                              builder: (context, tripSnapshot) {
                                return Text(
                                  tripSnapshot.data != null
                                      ? '${(tripSnapshot.data! / refuelEntrySnapshot.data!.refuelAmount * 10.0).round() / 10.0} km/L'
                                      : '--- km/L',
                                  textAlign: TextAlign.end,
                                  style: Theme.of(context).textTheme.titleLarge,
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 32.0,
                          ),
                          Text(_dateTimeString(
                              refuelEntrySnapshot.data!.dateTime)),
                          const Icon(Icons.navigate_next),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            separatorBuilder: (context, idx) => const Divider(),
            itemCount: itemsCountSnapshot.data!,
          );
        },
      ),
    );
  }
}
