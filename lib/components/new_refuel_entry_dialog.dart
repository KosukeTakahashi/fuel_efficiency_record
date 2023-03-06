import 'package:flutter/material.dart';
import 'package:fuel_efficiency_record/components/refuel_entry_editor.dart';

class NewRefuelEntryDialog extends StatelessWidget {
  const NewRefuelEntryDialog({
    super.key,
    required this.vehicleName,
  });

  final String vehicleName;

  @override
  Widget build(BuildContext context) {
    return RefuelEntryEditor(
      vehicleName: vehicleName,
      refuelEntry: null,
    );
  }
}
