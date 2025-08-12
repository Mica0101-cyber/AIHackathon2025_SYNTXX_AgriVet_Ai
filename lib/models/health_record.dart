class HealthRecord {
  final int? id;
  final int livestockId;
  final DateTime date;
  final String diagnosis;
  final String medicineUsed; // Medicine/Vaccine/Supplement used
  final String dosage;
  final String administeredBy;
  final String? notes;
  final String procedure; // Dropdown: Vaccination, Deworming, Castration, Treatment, Vitamin Supplementation, Others
  final String outcome; // Dropdown: Success, Failed

  HealthRecord({
    this.id,
    required this.livestockId,
    required this.date,
    required this.diagnosis,
    required this.medicineUsed,
    required this.dosage,
    required this.administeredBy,
    this.notes,
    required this.procedure,
    required this.outcome,
  });

  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'] as int?,
      livestockId: map['livestock_id'] as int,
      date: DateTime.parse(map['date']),
      diagnosis: map['diagnosis'] ?? '',
      medicineUsed: map['medicine_used'] ?? '',
      dosage: map['dosage'] ?? '',
      administeredBy: map['administered_by'] ?? '',
      notes: map['notes'],
      procedure: map['procedure'] ?? '',
      outcome: map['outcome'] ?? '',
    );
  }

  get treatment => null;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'livestock_id': livestockId,
      'date': date.toIso8601String(),
      'diagnosis': diagnosis,
      'medicine_used': medicineUsed,
      'dosage': dosage,
      'administered_by': administeredBy,
      'notes': notes,
      'procedure': procedure,
      'outcome': outcome,
    };
  }
}
