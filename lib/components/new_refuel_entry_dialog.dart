import 'package:flutter/material.dart';
import 'package:fuel_efficiency_record/models/refuel_entry.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:fuel_efficiency_record/constants.dart';

class NewRefuelEntryDialog extends StatefulWidget {
  const NewRefuelEntryDialog({super.key});

  @override
  State<StatefulWidget> createState() => _NewRefuelEntryDialogState();
}

class _NewRefuelEntryDialogState extends State<NewRefuelEntryDialog> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _totalPriceTextFieldController;
  late TextEditingController _dateTextFieldController;
  late TextEditingController _timeTextFieldController;
  late DateTime _dateTime;
  RefuelEntry? _prevRefuelEntry;
  double? _refuelAmount;
  int? _unitPrice;
  int? _totalPrice;
  int? _odometer;
  bool _isRegisterInProgress = false;

  static String? _intFormValidator(String? input) {
    if (input == null || input.isEmpty) {
      return null;
    }

    if (int.tryParse(input) == null) {
      return '整数を入力してください';
    }
    return null;
  }

  TableRow _buildStatsItem<T>(BuildContext context, Icon icon, String title,
          T value, String unit) =>
      TableRow(
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0), child: icon),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Text(
            '$value',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          Text(
            unit,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      );

  String _dateToString(DateTime dateTime) =>
      '${dateTime.year}/${dateTime.month}/${dateTime.day}';

  String _timeToString(TimeOfDay time) => '${time.hour}:${time.minute}';

  @override
  void initState() {
    super.initState();

    Future(() async {
      final db =
        await openDatabase(join(await getDatabasesPath(), refuelHistoryDBName));
      final prevRefuel = await db.query(
        refuelHistoryTableName,
        where:
        'timestamp = (SELECT MAX(${RefuelEntry.timestampFieldName}) FROM $refuelHistoryTableName)',
      );

      setState(() {
        if (prevRefuel.isNotEmpty) {
          _prevRefuelEntry = RefuelEntry.fromMap(prevRefuel[0]);
        }
        else {
          _prevRefuelEntry = null;
        }
      });
    });

    _formKey = GlobalKey();
    _dateTime = DateTime.now();
    _totalPriceTextFieldController = TextEditingController();
    _dateTextFieldController = TextEditingController(
      text: _dateToString(_dateTime),
    );
    _timeTextFieldController = TextEditingController(
      text: _timeToString(TimeOfDay.fromDateTime(_dateTime)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('新しい給油履歴'),
        actions: [
          if (_isRegisterInProgress)
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(),
            ),
          TextButton(
              onPressed: (_refuelAmount != null) &&
                      (_unitPrice != null) &&
                      (_totalPrice != null) &&
                      (_odometer != null)
                  ? () {
                      setState(() {
                        _isRegisterInProgress = true;
                      });
                      Future(() async {
                        final refuelEntry = RefuelEntry(
                          dateTime: _dateTime,
                          refuelAmount: _refuelAmount!,
                          unitPrice: _unitPrice!,
                          odometer: _odometer!,
                          totalPrice: _totalPrice!,
                        );
                        final db =
                          await openDatabase(join(await getDatabasesPath(), refuelHistoryDBName));
                        await db.insert(refuelHistoryTableName, refuelEntry.toMap(), conflictAlgorithm: ConflictAlgorithm.fail);
                        return 0;
                      }).then((_) {
                        setState(() {
                          _isRegisterInProgress = false;
                        });
                        Navigator.pop(context);
                      });
                    }
                  : null,
              child: const Text('保存')),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('給油情報'),
              const SizedBox(height: 16.0),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: '給油量',
                              suffixText: 'L',
                            ),
                            onChanged: (input) {
                              setState(() {
                                _refuelAmount = double.tryParse(input);
                                if (_refuelAmount != null &&
                                    _unitPrice != null) {
                                  _totalPrice =
                                      (_refuelAmount! * _unitPrice!).floor();
                                }
                              });
                              _formKey.currentState!.validate();

                              if (_refuelAmount != null && _unitPrice != null) {
                                _totalPriceTextFieldController.text =
                                    _totalPrice.toString();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: '単価',
                              suffixText: '円/L',
                            ),
                            onChanged: (input) {
                              setState(() {
                                _unitPrice = int.tryParse(input);
                                if (_refuelAmount != null &&
                                    _unitPrice != null) {
                                  _totalPrice =
                                      (_refuelAmount! * _unitPrice!).floor();
                                }
                              });
                              _formKey.currentState!.validate();

                              if (_refuelAmount != null && _unitPrice != null) {
                                _totalPriceTextFieldController.text =
                                    _totalPrice.toString();
                              }
                            },
                            validator: _intFormValidator,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _totalPriceTextFieldController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '総額',
                          suffixText: '円'),
                      onChanged: (input) {
                        setState(() {
                          _totalPrice = int.tryParse(input);
                        });
                        _formKey.currentState!.validate();
                      },
                      validator: _intFormValidator,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '現在の走行距離',
                        suffixText: 'km',
                      ),
                      onChanged: (input) {
                        setState(() {
                          _odometer = int.tryParse(input);
                        });
                        _formKey.currentState!.validate();
                      },
                      validator: _intFormValidator,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _dateTextFieldController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '日付',
                      ),
                      readOnly: true,
                      onTap: () async {
                        final dateTime = await showDatePicker(
                          context: context,
                          initialDate: _dateTime,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (dateTime != null) {
                          _dateTextFieldController.text =
                              _dateToString(dateTime);
                          setState(() {
                            _dateTime = _dateTime.copyWith(
                              year: dateTime.year,
                              month: dateTime.month,
                              day: dateTime.day,
                            );
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _timeTextFieldController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '時刻',
                      ),
                      readOnly: true,
                      onTap: () async {
                        final timeOfDay = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_dateTime),
                        );
                        if (timeOfDay != null) {
                          _timeTextFieldController.text =
                              _timeToString(timeOfDay);
                          setState(() {
                            _dateTime = _dateTime.copyWith(
                              hour: timeOfDay.hour,
                              minute: timeOfDay.minute,
                            );
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),
              const Text('今回の記録'),
              // const AverageFuelEfficiency(fuelEfficiency: 20.3),
              Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: const <int, TableColumnWidth>{
                  0: IntrinsicColumnWidth(),
                  1: IntrinsicColumnWidth(),
                  2: FlexColumnWidth(),
                  3: IntrinsicColumnWidth(),
                },
                children: [
                  _buildStatsItem(
                    context,
                    const Icon(Icons.drive_eta),
                    '前回からの走行距離',
                    (_prevRefuelEntry == null || _odometer == null)
                        ? '---'
                        : (_odometer! - _prevRefuelEntry!.odometer),
                    'km',
                  ),
                  _buildStatsItem(
                    context,
                    const Icon(Icons.speed),
                    '今回の平均燃費',
                    (_prevRefuelEntry == null ||
                            _odometer == null ||
                            _refuelAmount == null)
                        ? '---'
                        : ((_odometer! - _prevRefuelEntry!.odometer) /
                                    _refuelAmount! *
                                    10.0)
                                .round() /
                            10.0,
                    'km/L',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
