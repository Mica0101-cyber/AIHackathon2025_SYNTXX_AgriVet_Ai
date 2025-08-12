class FeedRecord {
  final int? id;
  final int livestockId;
  final DateTime datetime;
  final String feedType;
  final double amount;
  final String? notes; // ✅ Add notes field

  FeedRecord({
    this.id,
    required this.livestockId,
    required this.datetime,
    required this.feedType,
    required this.amount,
    this.notes, // ✅ Save to field
  });

  factory FeedRecord.fromMap(Map<String, dynamic> map) {
    return FeedRecord(
      id: _parseInt(map['id']),
      livestockId: _parseInt(map['livestock_id'] ?? map['livestockId']) ?? 0,
      datetime: _parseDate(map['datetime']),
      feedType: (map['feed_type'] ?? map['feedType'] ?? '').toString().trim(),
      amount: _parseDouble(map['amount']) ?? 0,
      notes: map['notes']?.toString(), // ✅ Load from DB
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'livestock_id': livestockId,
      'datetime': datetime.toIso8601String(),
      'feed_type': feedType,
      'amount': amount,
      'notes': notes, // ✅ Save to DB
    };
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
