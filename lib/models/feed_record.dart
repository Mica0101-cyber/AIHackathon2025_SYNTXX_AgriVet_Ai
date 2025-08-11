
class FeedRecord {
  final int? id;
  final int livestockId;
  final DateTime datetime;
  final String feedType;
  final double amount;

  FeedRecord({
    this.id,
    required this.livestockId,
    required this.datetime,
    required this.feedType,
    required this.amount,
  });

  /// Safely parse from a map, handling String/num for amount and date
  factory FeedRecord.fromMap(Map<String, dynamic> map) {
    final dynamic idRaw = map['id'];
    final dynamic livestockIdRaw = map['livestock_id'] ?? map['livestockId'];
    // Parse amount field
    final dynamic amountRaw = map['amount'];
    double parsedAmount;
    if (amountRaw is num) {
      parsedAmount = amountRaw.toDouble();
    } else if (amountRaw is String) {
      parsedAmount = double.tryParse(amountRaw) ?? 0;
    } else {
      parsedAmount = 0;
    }
    // Parse date field
    final dynamic dateRaw = map['datetime']; // <— this must match your column
    DateTime parsedDate;
    if (dateRaw is String) {
      parsedDate = DateTime.tryParse(dateRaw) ?? DateTime.now();
    } else if (dateRaw is DateTime) {
      parsedDate = dateRaw;
    } else {
      parsedDate = DateTime.now();
    }

    return FeedRecord(
      id: idRaw is int ? idRaw : int.tryParse(idRaw?.toString() ?? ''),
      livestockId: livestockIdRaw is int
          ? livestockIdRaw
          : int.tryParse(livestockIdRaw.toString()) ?? 0,
      datetime: parsedDate,
      feedType:
          (map['feed_type'] as String? ?? map['feed_type'] as String? ?? '')
              .trim(),
      amount: parsedAmount,
    );
  }

  /// Convert to map for insertion/updating
  Map<String, dynamic> toMap() {
    return {
      'livestock_id': livestockId, // <— this must match your column
      'datetime': datetime.toIso8601String(), // <— this must match your column
      'feed_type': feedType, // <— this must match your column
      'amount': amount, // <— this must match your column
    };
  }
}
