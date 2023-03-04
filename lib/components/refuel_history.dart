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
    return Column(
      children: refuelEntries.map((entry) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${entry.amount} L',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              // Text(
              //   '${0 < entry.key ? entry.value.odometer - refuelEntries[entry.key-1].odometer : '---'}km',
              //   style: Theme.of(context).textTheme.titleLarge,
              // ),
              Text(
                '${entry.price} 円',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                _showDateTime(entry.dateTime),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
        ),
      ).toList(),
    );
  }
}
