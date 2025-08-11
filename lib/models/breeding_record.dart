class BreedingRecord {
  final int? id;
  final int livestockId;
  final DateTime date; // instead of datetime
  final String feedType;
  final double amount; // in kg
  final String? notes; // optional
  final String type; // Weaning, Gestating, Farrowing, Lactating

  BreedingRecord({
    this.id,
    required this.livestockId,
    required this.date,
    required this.feedType,
    required this.amount,
    this.notes,
    required this.type,
  });

  factory BreedingRecord.fromMap(Map<String, dynamic> map) {
    // Parse date
    DateTime parsedDate;
    final dateRaw = map['date'];
    if (dateRaw is String) {
      parsedDate = DateTime.tryParse(dateRaw) ?? DateTime.now();
    } else if (dateRaw is DateTime) {
      parsedDate = dateRaw;
    } else {
      parsedDate = DateTime.now();
    }

    // Parse amount
    double parsedAmount;
    final amountRaw = map['amount'];
    if (amountRaw is num) {
      parsedAmount = amountRaw.toDouble();
    } else if (amountRaw is String) {
      parsedAmount = double.tryParse(amountRaw) ?? 0;
    } else {
      parsedAmount = 0;
    }

    return BreedingRecord(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id']?.toString() ?? ''),
      livestockId: map['livestock_id'] is int
          ? map['livestock_id']
          : int.tryParse(map['livestock_id']?.toString() ?? '') ?? 0,
      date: parsedDate,
      feedType: (map['feed_type'] as String? ?? '').trim(),
      amount: parsedAmount,
      notes: map['notes'] as String?,
      type: (map['type'] as String? ?? '').trim(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'livestock_id': livestockId,
      'date': date.toIso8601String(),
      'feed_type': feedType,
      'amount': amount,
      'notes': notes,
      'type': type,
    };
  }
}
