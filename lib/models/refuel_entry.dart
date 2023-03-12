class RefuelEntry {
  const RefuelEntry({
    required this.dateTime,
    required this.refuelAmount,
    required this.unitPrice,
    required this.odometer,
    required this.totalPrice,
    required this.isFullTank,
  });

  RefuelEntry.defaultPrice({
    required this.dateTime,
    required this.refuelAmount,
    required this.unitPrice,
    required this.odometer,
    required this.isFullTank,
  }) : totalPrice = (refuelAmount * unitPrice).floor();

  RefuelEntry.fromMap(Map<String, dynamic> map)
      : dateTime = DateTime.parse(map[dateTimeFieldName]),
        refuelAmount = map[refuelAmountFieldName],
        unitPrice = map[unitPriceFieldName],
        odometer = map[odometerFieldName],
        totalPrice = map[totalPriceFieldName],
        isFullTank = map[isFullTankFieldName] == 0 ? false : true;

  final DateTime dateTime;
  final double refuelAmount;
  final int unitPrice;
  final int odometer;
  final int totalPrice;
  final bool isFullTank;

  static String get timestampFieldName => 'timestamp';
  static String get dateTimeFieldName => 'datetime';
  static String get refuelAmountFieldName => 'refuel_amount';
  static String get unitPriceFieldName => 'unit_price';
  static String get odometerFieldName => 'odometer';
  static String get totalPriceFieldName => 'total_price';
  static String get isFullTankFieldName => 'is_full_tank';

  int get timestamp => (dateTime.millisecondsSinceEpoch / 1000).floor();

  Map<String, dynamic> toMap() => {
        timestampFieldName: timestamp,
        dateTimeFieldName: dateTime.toString(),
        refuelAmountFieldName: refuelAmount,
        unitPriceFieldName: unitPrice,
        odometerFieldName: odometer,
        totalPriceFieldName: totalPrice,
        isFullTankFieldName: isFullTank,
      };
}
