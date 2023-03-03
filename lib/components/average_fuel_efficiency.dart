import 'package:flutter/material.dart';

class AverageFuelEfficiency extends StatelessWidget {
  const AverageFuelEfficiency({
    super.key,
    required this.fuelEfficiency,
  });

  final double fuelEfficiency;

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
                '平均燃費',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '平均',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text('$fuelEfficiency',
                        style: Theme.of(context).textTheme.displayLarge),
                    Text(
                      'km/L',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
