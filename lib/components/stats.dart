import 'package:flutter/material.dart';

class Stats extends StatelessWidget {
  const Stats({
    super.key,
    required this.fuelEfficiency,
    required this.odometer,
  });

  final double fuelEfficiency;
  final int odometer;

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
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: Card(
          elevation: 0,
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '統計',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                  const Divider(),
                  Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: const <int, TableColumnWidth>{
                      0: IntrinsicColumnWidth(),
                      1: FlexColumnWidth(),
                      2: FixedColumnWidth(16.0),
                      3: IntrinsicColumnWidth(),
                    },
                    children: [
                      _statsItem(context, '最高燃費', fuelEfficiency, 'km/L'),
                      _statsItem(context, '走行距離', odometer, 'km'),
                      _statsItem(context, '総給油量', fuelEfficiency, 'L'),
                    ],
                  ),
                ],
              )
          ),
        )
    );
  }
}
