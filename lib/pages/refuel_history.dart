import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fuel_efficiency_record/models/refuel_entry.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:fuel_efficiency_record/constants.dart';

class RefuelHistoryPage extends StatefulWidget {
  const RefuelHistoryPage({super.key});

  @override
  State<StatefulWidget> createState() => _RefuelHistoryPageState();
}

class _RefuelHistoryPageState extends State<RefuelHistoryPage> {
  Database? _db;

  Future<Database> _openDatabase() async {
    return await openDatabase(join(await getDatabasesPath(), refuelHistoryDBName));
  }

  Future<int> _countRefuelEntries() async {
    _db ??= await _openDatabase();
    final res = await _db!
        .rawQuery('SELECT COUNT(*) AS count FROM $refuelHistoryTableName');
    return res[0]['count'] as int;
  }

  Future<RefuelEntry?> _getRefuelEntry(int index) async {
    _db ??= await _openDatabase();
    final res = await _db!.rawQuery('SELECT * FROM '
        '(SELECT *, Row_Number() '
        'OVER(ORDER BY ${RefuelEntry.timestampFieldName} DESC) as RNK '
        'FROM $refuelHistoryTableName) T1 WHERE RNK = ${index + 1}');
    if (res.isNotEmpty) {
      return RefuelEntry.fromMap(res[0]);
    }
    return null;
  }

  Future<int?> _getTrip(int timestamp) async {
    _db ??= await _openDatabase();
    final tripsRes = await _db!.rawQuery('SELECT '
        'H1.${RefuelEntry.odometerFieldName} - H2.${RefuelEntry.odometerFieldName} AS trip '
        'FROM $refuelHistoryTableName H1, $refuelHistoryTableName H2 '
        'WHERE H1.${RefuelEntry.timestampFieldName} = $timestamp '
        'AND H2.${RefuelEntry.timestampFieldName} = '
        '(SELECT MAX(${RefuelEntry.timestampFieldName}) FROM $refuelHistoryTableName WHERE ${RefuelEntry.timestampFieldName} < H1.${RefuelEntry.timestampFieldName});');
    if (tripsRes.isNotEmpty) {
      return tripsRes[0]['trip'] as int;
    }
    return null;
  }

  String _dateTimeString(DateTime dateTime) =>
      DateFormat('yyyy/MM/dd HH:mm').format(dateTime);

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
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: '全て削除',
              color: Colors.red,
              onPressed: () async {
                _db ??= await _openDatabase();
                await _db!.delete(refuelHistoryTableName);
                setState(() {});
              },
            )
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
                      onTap: () {},
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
                                Text('${refuelEntrySnapshot.data!.totalPrice} 円'),
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
                                        ? '${(tripSnapshot.data! / refuelEntrySnapshot.data!.refuelAmount * 10.0).floor() / 10.0} km/L'
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
        ));
  }
}
