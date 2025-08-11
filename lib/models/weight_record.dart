// lib/models/weight_record.dart
class WeightRecord {
  final int? id;
  final int livestockId;
  final DateTime datetime;
  final double weight;

  WeightRecord({
    this.id,
    required this.livestockId,
    required this.datetime,
    required this.weight,
  });

  factory WeightRecord.fromMap(Map<String, dynamic> map) {
    final idRaw = map['id'];
    final livestockIdRaw = map['livestock_id'] ?? map['livestockId'];
    final dateRaw = map['datetime'];
    final weightRaw = map['weight'];

    return WeightRecord(
      id: idRaw is int ? idRaw : int.tryParse('${idRaw ?? ''}'),
      livestockId: livestockIdRaw is int
          ? livestockIdRaw
          : int.tryParse('${livestockIdRaw ?? ''}') ?? 0,
      datetime: dateRaw is DateTime
          ? dateRaw
          : DateTime.tryParse('${dateRaw ?? ''}') ?? DateTime.now(),
      weight: weightRaw is num
          ? weightRaw.toDouble()
          : double.tryParse('${weightRaw ?? 0}') ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'livestock_id': livestockId,
        'datetime': datetime.toIso8601String(),
        'weight': weight,
      };
}
