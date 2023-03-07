import 'package:flutter/material.dart';
import 'package:fuel_efficiency_record/constants.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class VehicleNameDialog extends StatefulWidget {
  const VehicleNameDialog({
    super.key,
    this.currentName,
  });

  final String? currentName;

  @override
  State<StatefulWidget> createState() => _VehicleNameDialogState();
}

class _VehicleNameDialogState extends State<VehicleNameDialog> {
  late GlobalKey<FormState> _globalKey;
  late TextEditingController _vehicleNameTextFieldController;

  List<String>? _vehicleNames;
  bool _isValidName = false;

  @override
  void initState() {
    super.initState();

    _globalKey = GlobalKey();
    _vehicleNameTextFieldController = TextEditingController();

    if (widget.currentName != null) {
      _vehicleNameTextFieldController.text = widget.currentName!;
    }

    Future(() async {
      final db = await openDatabase(
          join(await getDatabasesPath(), refuelHistoryDBName));
      final vehiclesRes = await db.query(vehicleNameTable);
      setState(() {
        _vehicleNames = vehiclesRes.map((row) => row['name'] as String).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.currentName == null
          ? const Text('車両を追加')
          : const Text('車両名を変更'),
      content: _vehicleNames == null
          ? Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                SizedBox(
                  width: 32.0,
                  height: 32.0,
                  child: CircularProgressIndicator(),
                )
              ],
            )
          : Form(
              key: _globalKey,
              child: TextFormField(
                controller: _vehicleNameTextFieldController,
                validator: (input) {
                  if (input == null || input.isEmpty) {
                    setState(() {
                      _isValidName = true;
                    });
                    return null;
                  }

                  if (widget.currentName == input) {
                    setState(() {
                      _isValidName = false;
                    });
                    return '同じ車両名です';
                  }

                  if (_vehicleNames!.contains(input)) {
                    setState(() {
                      _isValidName = false;
                    });
                    return '同名の車両が既に存在します';
                  }

                  setState(() {
                    _isValidName = true;
                  });
                  return null;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '車両名',
                ),
                onChanged: (input) {
                  _globalKey.currentState!.validate();
                },
              ),
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
          onPressed: _vehicleNameTextFieldController.text.isEmpty ||
                  !_isValidName
              ? null
              : () {
                  Future(() async {
                    final db = await openDatabase(
                        join(await getDatabasesPath(), refuelHistoryDBName));
                    if (widget.currentName != null) {
                      await db.execute(
                          'ALTER TABLE ${widget.currentName} RENAME TO ${_vehicleNameTextFieldController.text};');
                      await db.delete(vehicleNameTable,
                          where: 'name = "${widget.currentName}"');
                    }
                    await db.insert(
                      vehicleNameTable,
                      {
                        'name': _vehicleNameTextFieldController.text,
                      },
                      conflictAlgorithm: ConflictAlgorithm.fail,
                    );
                  });

                  Navigator.of(context).pop();
                },
          child:
              widget.currentName == null ? const Text('追加') : const Text('変更'),
        )
      ],
    );
  }
}
