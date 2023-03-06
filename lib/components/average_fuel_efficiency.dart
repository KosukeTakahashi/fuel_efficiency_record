import 'package:flutter/material.dart';

class AverageFuelEfficiency extends StatelessWidget {
  const AverageFuelEfficiency({
    super.key,
    required this.fuelEfficiency,
  });

  final double? fuelEfficiency;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            '平均',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          flex: 0,
          child: Text(
              fuelEfficiency == null || fuelEfficiency!.isNaN
                  ? '---'
                  : ((fuelEfficiency! * 10.0).round() / 10.0).toString(),
              style: Theme.of(context).textTheme.displayLarge),
        ),
        Expanded(
          flex: 1,
          child: Text(
            'km/L',
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ],
    );
  }
}
