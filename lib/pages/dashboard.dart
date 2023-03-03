import 'package:flutter/material.dart';
import 'package:fuel_efficiency_record/components/average_fuel_efficiency.dart';
import 'package:fuel_efficiency_record/components/stats.dart';
import 'package:fuel_efficiency_record/components/refuel_history.dart';
import 'package:fuel_efficiency_record/models/refuel_entry.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: [
            const SizedBox(
              width: double.infinity,
              height: 16.0,
            ),
            const AverageFuelEfficiency(fuelEfficiency: 20.3),
            const Stats(fuelEfficiency: 22.4, odometer: 125847),
            RefuelHistory(
              refuelEntries: [
                for (int i = 0; i < 8; i++)
                  RefuelEntry(
                    dateTime: DateTime.now(),
                    amount: 16.83,
                    unitPrice: 148
                  ),
              ],
            ),
            const SizedBox(
              width: double.infinity,
              height: 92.0,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.local_gas_station),
        label: const Text('給油'),
        onPressed: () {},
      ),
    );
  }
}
