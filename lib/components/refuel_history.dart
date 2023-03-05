import 'package:flutter/material.dart';
import 'package:fuel_efficiency_record/models/refuel_entry.dart';

class RefuelHistory extends StatelessWidget {
  const RefuelHistory({
    super.key,
    required this.refuelEntries,
  });

  final List<RefuelEntry> refuelEntries;

  static String _showDateTime(DateTime d) {
    return '${d.year}/${d.month}/${d.day} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // return Column(
    //   children: refuelEntries.map((entry) =>
    //     Padding(
    //       padding: const EdgeInsets.symmetric(vertical: 16.0),
    //       child: Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //         children: [
    //           Text(
    //             '${entry.refuelAmount} L',
    //             style: Theme.of(context).textTheme.titleLarge,
    //           ),
    //           // Text(
    //           //   '${0 < entry.key ? entry.value.odometer - refuelEntries[entry.key-1].odometer : '---'}km',
    //           //   style: Theme.of(context).textTheme.titleLarge,
    //           // ),
    //           Text(
    //             '${entry.totalPrice} 円',
    //             style: Theme.of(context).textTheme.titleLarge,
    //           ),
    //           Text(
    //             _showDateTime(entry.dateTime),
    //             style: Theme.of(context).textTheme.titleSmall,
    //           ),
    //         ],
    //       ),
    //     ),
    //   ).toList(),
    // );
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
        2: FixedColumnWidth(16.0),
        3: IntrinsicColumnWidth()
      },
      children: refuelEntries.map((entry) =>
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '${entry.refuelAmount} L',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '${entry.totalPrice} 円',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.end,
                ),
              ),
              Container(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _showDateTime(entry.dateTime),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
      ).toList(),
    );
  }
}
