import 'package:flutter/material.dart';
import 'package:fuel_efficiency_record/components/stats.dart';
import 'package:fuel_efficiency_record/components/refuel_history.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('燃費記録'),
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Stats(fuelEfficiency: 22.4, odometer: 25847.0),
            const RefuelHistory(),
          ],
        ),
      ),
    );
  }
}
