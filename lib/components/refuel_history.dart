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
                  '給油履歴',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                const Divider(),
                ...refuelEntries.map((entry) =>
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${entry.amount} L',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          _showDateTime(entry.dateTime),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
        ),
      )
    );
  }
}
