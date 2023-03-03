class RefuelEntry {
  const RefuelEntry({
    required this.dateTime,
    required this.amount,
    required this.unitPrice,
  });

  final DateTime dateTime;
  final double amount;
  final int unitPrice;
}
