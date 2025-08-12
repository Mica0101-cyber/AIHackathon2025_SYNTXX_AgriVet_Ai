// lib/models/breeding_record.dart
class BreedingRecord {
  final int? id;
  final int livestockId;
  final DateTime datetime;
  final String method;
  final String? breedingType;
  final String? pigletBorn;
  final String? notes;
  final DateTime? createdAt;

  BreedingRecord({
    this.id,
    required this.livestockId,
    required this.datetime,
    required this.method,
    this.breedingType,
    this.pigletBorn,
    this.notes,
    this.createdAt,
  });

  factory BreedingRecord.fromMap(Map<String, dynamic> map) {
    return BreedingRecord(
      id: map['id'] as int?,
      livestockId: map['livestock_id'] as int,
      datetime: DateTime.parse(map['datetime']),
      method: map['method'] as String,
      breedingType: map['breeding_type'] as String?,
      pigletBorn: map['piglet_born'] as String?,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : null,
    );
  }

  DateTime? get date => null;

  get maleId => null;

  get status => null;

  get femaleId => null;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'livestock_id': livestockId,
      'datetime': datetime.toIso8601String().split('T').first,
      'method': method,
      if (breedingType != null) 'breeding_type': breedingType,
      if (pigletBorn != null) 'piglet_born': pigletBorn,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}