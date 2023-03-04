import 'package:flutter/material.dart';
import 'package:fuel_efficiency_record/components/average_fuel_efficiency.dart';
import 'package:fuel_efficiency_record/components/dashboard_card.dart';
import 'package:fuel_efficiency_record/components/new_refuel_entry_dialog.dart';
import 'package:fuel_efficiency_record/components/stats.dart';
import 'package:fuel_efficiency_record/components/refuel_history.dart';
import 'package:fuel_efficiency_record/models/refuel_entry.dart';
import 'package:fuel_efficiency_record/routes/slide_fade_in_route.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('燃費記録'),
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
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
            const DashboardCard(
              title: '平均燃費',
              child: AverageFuelEfficiency(fuelEfficiency: 20.3)),
            const DashboardCard(
              title: '統計',
              child: Stats(
                bestFuelEfficiency: 22.4,
                odometer: 125847,
                totalFuelAmount: 300,
              ),
            ),
            DashboardCard(
              title: '給油履歴',
              child: RefuelHistory(
                refuelEntries: [
                  for (int i = 0; i < 8; i++)
                    RefuelEntry.defaultPrice(
                      dateTime: DateTime.now(),
                      amount: 16.83,
                      unitPrice: 148,
                      odometer: 12000 + 100 * i,
                    ),
                ],
              ),
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
        onPressed: () async {
          // showDialog(
          //   context: context,
          //   barrierColor: Theme.of(context).colorScheme.surface,
          //   builder: (BuildContext context) => const Dialog.fullscreen(
          //     child: NewRefuelEntryDialog(),
          //   ),
          // );
          await Navigator.of(context)
              .push(SlideFadeInRoute(widget: const NewRefuelEntryDialog()));
          // await Navigator.of(context).push(MaterialPageRoute(
          //   builder: (context) => const NewRefuelEntryDialog()
          // ));
        },
      ),
    );
  }
}
