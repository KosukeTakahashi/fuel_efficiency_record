import 'package:flutter/material.dart';

class Stats extends StatelessWidget {
  const Stats({
    super.key,
    required this.fuelEfficiency,
    required this.odometer,
  });

  final double fuelEfficiency;
  final double odometer;

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
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Divider(),
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                          flex: 1,
                          child: Text('平均燃費'),
                        ),
                        const Flexible(
                          flex: 1,
                          child: SizedBox(width: double.infinity),
                        ),
                        Flexible(
                          flex: 0,
                          child: Text(
                            '$fuelEfficiency',
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ),
                        Flexible(
                            flex: 1,
                            child: Text(
                              'km/L',
                              style: Theme.of(context).textTheme.displaySmall,
                            )
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                          flex: 1,
                          child: Text('走行距離'),
                        ),
                        const Flexible(
                          flex: 1,
                          child: SizedBox(width: double.infinity),
                        ),
                        Flexible(
                          flex: 0,
                          child: Text(
                            '$odometer',
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ),
                        Flexible(
                            flex: 1,
                            child: Text(
                              'km',
                              style: Theme.of(context).textTheme.displaySmall,
                            )
                        ),
                      ],
                    ),
                  ),
                ],
              )
          ),
        )
    );
  }
}
