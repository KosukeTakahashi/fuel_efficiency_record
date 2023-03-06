import 'package:flutter/material.dart';
import 'package:fuel_efficiency_record/constants.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class NewVehicleDialog extends StatefulWidget {
  const NewVehicleDialog({super.key});

  @override
  State<StatefulWidget> createState() => _NewVehicleDialogState();
}

class _NewVehicleDialogState extends State<NewVehicleDialog> {
  late GlobalKey<FormState> _globalKey;
  late TextEditingController _vehicleNameTextFieldController;

  @override
  void initState() {
    super.initState();

    _globalKey = GlobalKey();
    _vehicleNameTextFieldController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('車両を追加'),
      content: FutureBuilder(
        future: () async {
          final db = await openDatabase(
              join(await getDatabasesPath(), refuelHistoryDBName));
          final vehiclesRes = await db.query(vehicleNameTable);
          return vehiclesRes.map((row) => row['name'] as String).toList();
        }(),
        builder: (context, vehiclesSnapshot) {
          return Form(
            key: _globalKey,
            child: TextFormField(
              controller: _vehicleNameTextFieldController,
              validator: (input) {
                if (input == null || input.isEmpty) {
                  return null;
                }

                if (vehiclesSnapshot.data?.contains(input) ?? false) {
                  return '同名の車両が既に存在します';
                }

                return null;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '車両名',
              ),
              onChanged: (input) {
                _globalKey.currentState!.validate();
                setState(() {});
              },
            ),
          );
        },
      ),
      actions: [
        TextButton(
          child: const Text('キャンセル'),
          onPressed: () {
            _vehicleNameTextFieldController.text = '';
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          onPressed: _vehicleNameTextFieldController.text.isEmpty
              ? null
              : () {
                  Future(() async {
                    final db = await openDatabase(
                        join(await getDatabasesPath(), refuelHistoryDBName));
                    await db.insert(vehicleNameTable, {
                      'name': _vehicleNameTextFieldController.text,
                    });
                  });

                  Navigator.of(context).pop();
                },
          child: const Text('追加'),
        )
      ],
    );
  }
}
