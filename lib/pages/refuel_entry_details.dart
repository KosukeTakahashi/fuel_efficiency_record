import 'package:flutter/material.dart';
import 'package:fuel_efficiency_record/models/refuel_entry.dart';
import 'package:intl/intl.dart';

class RefuelEntryDetailsPageArgs {
  const RefuelEntryDetailsPageArgs({
    required this.refuelEntry,
  });

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
  static final _dateTimeString = DateFormat('yyyy/MM/dd hh:mm').format;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final refuelEntry = widget.refuelEntryArgs.refuelEntry;
    return Scaffold(
      appBar: AppBar(
        title: const Text('給油履歴詳細'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: refuelEntry == null
          ? const Center(
              child: Text('ERR!'),
            )
          : SingleChildScrollView(
              child: Text(_dateTimeString(refuelEntry.dateTime)),
            ),
    );
  }
}
