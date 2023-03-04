class RefuelEntry {
  const RefuelEntry({
    required this.dateTime,
    required this.amount,
    required this.unitPrice,
    required this.odometer,
    required this.price,
  });

  RefuelEntry.defaultPrice({
    required this.dateTime,
    required this.amount,
    required this.unitPrice,
    required this.odometer,
  }) : price = (amount * unitPrice).floor();

  final DateTime dateTime;
  final double amount;
  final int unitPrice;
  final int odometer;
  final int price;
}
