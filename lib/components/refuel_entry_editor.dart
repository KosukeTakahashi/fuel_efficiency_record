import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:fuel_efficiency_record/models/refuel_entry.dart';
import 'package:fuel_efficiency_record/constants.dart';

class RefuelEntryEditor extends StatefulWidget {
  const RefuelEntryEditor({
    super.key,
    required this.vehicleName,
    required this.refuelEntry,
  });

  final String vehicleName;
  final RefuelEntry? refuelEntry;

  @override
  State<StatefulWidget> createState() => _RefuelEntryEditorState();
}

class _RefuelEntryEditorState extends State<RefuelEntryEditor> {
  late GlobalKey<FormState> _intFormKey;
  late GlobalKey<FormState> _dateTimeFormKey;
  late TextEditingController _refuelAmountTextFieldController;
  late TextEditingController _unitPriceTextFieldController;
  late TextEditingController _totalPriceTextFieldController;
  late TextEditingController _odometerTextFieldController;
  late TextEditingController _dateTextFieldController;
  late TextEditingController _timeTextFieldController;
  late DateTime _dateTime;
  RefuelEntry? _prevRefuelEntry;
  RefuelEntry? _nextRefuelEntry;
  double? _refuelAmount;
  int? _unitPrice;
  int? _totalPrice;
  int? _odometer;
  bool _isFullTank = true;
  double? _totalRefuelAmount; // 前回の満タン給油からの総給油量
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

  // String _dateToString(DateTime dateTime) =>
  //     '${dateTime.year}/${dateTime.month}/${dateTime.day}';
  final String Function(DateTime) _dateToString =
      DateFormat('yyyy/MM/dd').format;

  // String _timeToString(TimeOfDay time) => '${time.hour}:${time.minute}';
  final String Function(DateTime) _timeToString = DateFormat('HH:mm').format;

  bool _isValidOdometer(int odometer) =>
      (_prevRefuelEntry == null
          ? true
          : _prevRefuelEntry!.odometer < odometer) &&
      (_nextRefuelEntry == null ? true : odometer < _nextRefuelEntry!.odometer);

  void _setRefuelEntryData() {
    _dateTime = widget.refuelEntry!.dateTime;
    _refuelAmount = widget.refuelEntry!.refuelAmount;
    _unitPrice = widget.refuelEntry!.unitPrice;
    _totalPrice = widget.refuelEntry!.totalPrice;
    _odometer = widget.refuelEntry!.odometer;

    _refuelAmountTextFieldController.text =
        widget.refuelEntry!.refuelAmount.toString();
    _unitPriceTextFieldController.text =
        widget.refuelEntry!.unitPrice.toString();
    _totalPriceTextFieldController.text =
        widget.refuelEntry!.totalPrice.toString();
    _odometerTextFieldController.text = widget.refuelEntry!.odometer.toString();
    _dateTextFieldController.text = _dateToString(widget.refuelEntry!.dateTime);
    _timeTextFieldController.text = _timeToString(widget.refuelEntry!.dateTime);
    setState(() {
      _isFullTank = widget.refuelEntry!.isFullTank;
    });
  }

  @override
  void initState() {
    super.initState();

    Future(() async {
      final db = await openDatabase(
          join(await getDatabasesPath(), refuelHistoryDBName));
      final prevRefuelRes = await db.query(
        widget.vehicleName,
        where:
            '${RefuelEntry.timestampFieldName} = (SELECT MAX(${RefuelEntry.timestampFieldName}) '
            'FROM ${widget.vehicleName} '
            'WHERE ${RefuelEntry.isFullTankFieldName} <> 0 '
            '${widget.refuelEntry == null ? '' : 'AND ${RefuelEntry.timestampFieldName} < ${widget.refuelEntry!.timestamp}'})',
      );
      final totalRefuelAmountRes = await db.rawQuery('SELECT '
          'SUM(${RefuelEntry.refuelAmountFieldName}) as total_refuel '
          'FROM ${widget.vehicleName} '
          'WHERE ${RefuelEntry.isFullTankFieldName} = 0 '
          '${widget.refuelEntry == null ? '' : 'AND ${RefuelEntry.timestampFieldName} < ${widget.refuelEntry!.timestamp}'};');

      setState(() {
        if (prevRefuelRes.isNotEmpty) {
          _prevRefuelEntry = RefuelEntry.fromMap(prevRefuelRes[0]);
        } else {
          _prevRefuelEntry = null;
        }
        _totalRefuelAmount = totalRefuelAmountRes[0]['total_refuel'] as double?;
      });

      if (widget.refuelEntry != null) {
        final nextRefuelRes = await db.query(
          widget.vehicleName,
          where:
              '${RefuelEntry.timestampFieldName} = (SELECT MIN(${RefuelEntry.timestampFieldName}) FROM '
              '${widget.vehicleName} WHERE ${RefuelEntry.timestampFieldName} > ${widget.refuelEntry!.timestamp})',
        );

        setState(() {
          if (nextRefuelRes.isNotEmpty) {
            _nextRefuelEntry = RefuelEntry.fromMap(nextRefuelRes[0]);
          } else {
            _nextRefuelEntry = null;
          }
        });
      }
    });

    _intFormKey = GlobalKey();
    _dateTimeFormKey = GlobalKey();
    _dateTime = DateTime.now();
    _refuelAmountTextFieldController = TextEditingController();
    _unitPriceTextFieldController = TextEditingController();
    _totalPriceTextFieldController = TextEditingController();
    _odometerTextFieldController = TextEditingController();
    _dateTextFieldController = TextEditingController();
    _timeTextFieldController = TextEditingController();

    if (widget.refuelEntry != null) {
      _setRefuelEntryData();
    } else {
      _dateTime = DateTime.now();
      _dateTextFieldController.text = _dateToString(_dateTime);
      _timeTextFieldController.text = _timeToString(_dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: widget.refuelEntry == null
              ? const Icon(Icons.close)
              : const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: widget.refuelEntry == null
            ? const Text('新しい給油履歴')
            : const Text('給油履歴の詳細'),
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
                      (_odometer != null) &&
                      _isValidOdometer(_odometer!)
                  ? () {
                      setState(() {
                        _isRegisterInProgress = true;
                      });
                      Future(() async {
                        final newRefuelEntry = RefuelEntry(
                          dateTime: _dateTime,
                          refuelAmount: _refuelAmount!,
                          unitPrice: _unitPrice!,
                          odometer: _odometer!,
                          totalPrice: _totalPrice!,
                          isFullTank: _isFullTank,
                        );
                        final db = await openDatabase(join(
                            await getDatabasesPath(), refuelHistoryDBName));
                        if (widget.refuelEntry != null) {
                          if (widget.refuelEntry!.dateTime != _dateTime) {
                            await db.delete(
                              widget.vehicleName,
                              where:
                                  'timestamp = ${widget.refuelEntry!.timestamp}',
                            );
                          }
                        }
                        await db.insert(
                            widget.vehicleName, newRefuelEntry.toMap(),
                            conflictAlgorithm: ConflictAlgorithm.replace);
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
              Row(
                children: [
                  Checkbox(
                      value: _isFullTank,
                      onChanged: (v) {
                        setState(() {
                          _isFullTank = v ?? false;
                        });
                      }),
                  const Text('満タン'),
                  IconButton(
                    icon: const Icon(Icons.help),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('「満タン」フラグ'),
                            content: const Text('満タン給油でない場合、前回給油からの燃料消費量が不明なため、燃費が計算できません。この場合、次回満タン給油時に、今回の給油を含めて燃費を計算します。'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Form(
                key: _intFormKey,
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: _refuelAmountTextFieldController,
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
                              _intFormKey.currentState!.validate();

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
                            controller: _unitPriceTextFieldController,
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
                              _intFormKey.currentState!.validate();

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
                      keyboardType: TextInputType.number,
                      controller: _totalPriceTextFieldController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '総額',
                          suffixText: '円'),
                      onChanged: (input) {
                        setState(() {
                          _totalPrice = int.tryParse(input);
                        });
                        _intFormKey.currentState!.validate();
                      },
                      validator: _intFormValidator,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: _odometerTextFieldController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '現在の走行距離',
                        suffixText: 'km',
                      ),
                      onChanged: (input) {
                        setState(() {
                          _odometer = int.tryParse(input);
                        });
                        _intFormKey.currentState!.validate();
                      },
                      validator: (input) {
                        if (input == null || input.isEmpty) {
                          return null;
                        }

                        final isInt = _intFormValidator(input);
                        if (isInt != null) {
                          return isInt;
                        }

                        final odometer = int.parse(input);
                        if (_prevRefuelEntry != null) {
                          if (odometer < _prevRefuelEntry!.odometer) {
                            return '過去の走行距離を下回っています';
                          }
                        }

                        if (_nextRefuelEntry != null) {
                          if (_nextRefuelEntry!.odometer < odometer) {
                            return '次の給油履歴の走行距離を上回っています';
                          }
                        }

                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Form(
                key: _dateTimeFormKey,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            firstDate: _prevRefuelEntry == null
                                ? DateTime(2020)
                                : _prevRefuelEntry!.dateTime
                                    .add(const Duration(minutes: 1)),
                            lastDate: _nextRefuelEntry == null
                                ? DateTime.now()
                                : _nextRefuelEntry!.dateTime
                                    .subtract(const Duration(minutes: 1)),
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

                          _dateTimeFormKey.currentState!.validate();
                        },
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
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
                            // _timeTextFieldController.text =
                            //     _timeToString(timeOfDay);
                            setState(() {
                              _dateTime = _dateTime.copyWith(
                                hour: timeOfDay.hour,
                                minute: timeOfDay.minute,
                              );
                            });
                            _timeTextFieldController.text =
                                _timeToString(_dateTime);
                          }
                          _dateTimeFormKey.currentState!.validate();
                        },
                        validator: (input) {
                          if (_prevRefuelEntry != null) {
                            if (_prevRefuelEntry!.dateTime
                                    .difference(_dateTime)
                                    .inSeconds >
                                0) {
                              return '過去の給油履歴より\n以前の時刻です';
                            }
                          }
                          if (_nextRefuelEntry != null) {
                            if (_nextRefuelEntry!.dateTime
                                    .difference(_dateTime)
                                    .inSeconds <
                                0) {
                              return '次の給油履歴より\n後の時刻です';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
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
                        : (_odometer! < _prevRefuelEntry!.odometer)
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
                            _refuelAmount == null ||
                            (!_isFullTank))
                        ? '---'
                        : (_odometer! < _prevRefuelEntry!.odometer)
                            ? '---'
                            : ((_odometer! - _prevRefuelEntry!.odometer) /
                                        (_refuelAmount! +
                                            (_totalRefuelAmount ?? 0.0)) *
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
