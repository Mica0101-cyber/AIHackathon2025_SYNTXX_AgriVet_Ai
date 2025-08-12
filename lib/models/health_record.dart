class HealthRecord {
  final int? id;
  final int livestockId;
  final DateTime date;
  final String procedure;
  final String diagnosis;
  final String medicineUsed;
  final String dosage;
  final String administeredBy;
  final String outcome;
  final String notes;

  HealthRecord({
    this.id,
    required this.livestockId,
    required this.date,
    required this.procedure,
    required this.diagnosis,
    required this.medicineUsed,
    required this.dosage,
    required this.administeredBy,
    required this.outcome,
    required this.notes,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'] as int?,
      livestockId: json['livestock_id'] as int,
      date: DateTime.parse(json['date']),
      procedure: json['procedure'] ?? '',
      diagnosis: json['diagnosis'] ?? '',
      medicineUsed: json['medicine_used'] ?? '',
      dosage: json['dosage'] ?? '',
      administeredBy: json['administered_by'] ?? '',
      outcome: json['outcome'] ?? '',
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'livestock_id': livestockId,
      'date': date.toIso8601String(),
      'procedure': procedure,
      'diagnosis': diagnosis,
      'medicine_used': medicineUsed,
      'dosage': dosage,
      'administered_by': administeredBy,
      'outcome': outcome,
      'notes': notes,
    };
  }
}
