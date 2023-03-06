import 'package:flutter/material.dart';
import 'package:fuel_efficiency_record/components/refuel_entry_editor.dart';
import 'package:fuel_efficiency_record/models/refuel_entry.dart';

class RefuelEntryDetailsPageArgs {
  const RefuelEntryDetailsPageArgs({
    required this.vehicleName,
    required this.refuelEntry,
  });

  final String vehicleName;
  final RefuelEntry? refuelEntry;
}

class RefuelEntryDetailsPage extends StatefulWidget {
  const RefuelEntryDetailsPage({
    super.key,
    required this.refuelEntryArgs,
  });

  final RefuelEntryDetailsPageArgs refuelEntryArgs;

  @override
  State<StatefulWidget> createState() => _RefuelEntryDetailsPageState();
}

class _RefuelEntryDetailsPageState extends State<RefuelEntryDetailsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final vehicleName = widget.refuelEntryArgs.vehicleName;
    final refuelEntry = widget.refuelEntryArgs.refuelEntry;
    return RefuelEntryEditor(
      vehicleName: vehicleName,
      refuelEntry: refuelEntry,
    );
  }
}
