import 'package:flutter/material.dart';

class Stats extends StatelessWidget {
  const Stats({
    super.key,
    required this.bestFuelEfficiency,
    required this.odometer,
    required this.totalFuelAmount,
  });

  final double bestFuelEfficiency;
  final int odometer;
  final int totalFuelAmount;

  TableRow _statsItem<T>(BuildContext context, String title, T value, String unit) =>
      TableRow(
        children: [
          Text(title),
          Text(
            '$value',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.end,
          ),
          const SizedBox(),
          Text(
            unit,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
        2: FixedColumnWidth(16.0),
        3: IntrinsicColumnWidth(),
      },
      children: [
        _statsItem(context, '最高燃費', bestFuelEfficiency, 'km/L'),
        _statsItem(context, '走行距離', odometer, 'km'),
        _statsItem(context, '総給油量', totalFuelAmount, 'L'),
      ],
    );
  }
}
