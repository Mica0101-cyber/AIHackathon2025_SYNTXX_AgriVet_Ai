class Livestock {
  final int? id;
  final String name;
  final String? type; // Assuming type is a String, adjust as necessary
  final String? status; // Assuming type is a String, adjust as necessary
  final DateTime dateOfBirth;
  final String breed;
  final String tagNumber;

  Livestock({
    this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.dateOfBirth,
    required this.breed,
    required this.tagNumber,
  });

  /// Creates a Livestock instance from a Supabase map, expecting camelCase keys
  factory Livestock.fromMap(Map<String, dynamic> map) {
    // Parse dateOfBirth, handling both String and DateTime
    final dobRaw = map['dateOfBirth'];
    DateTime parsedDob;
    if (dobRaw is String && dobRaw.isNotEmpty) {
      parsedDob = DateTime.tryParse(dobRaw) ?? DateTime.now();
    } else if (dobRaw is DateTime) {
      parsedDob = dobRaw;
    } else {
      parsedDob = DateTime.now();
    }

    return Livestock(
      id: map['id'] as int?,
      name: (map['name'] as String?)?.trim() ?? '',
      type: (map['type'] as String?)?.trim() ?? '',
      status: (map['status'] as String?)?.trim() ?? '',
      dateOfBirth: parsedDob,
      breed: (map['breed'] as String?)?.trim() ?? '',
      tagNumber: (map['tagNumber'] as String?)?.trim() ?? '',
    );
  }

  /// Converts a Livestock instance to a map for insertion/updating, using camelCase keys
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'breed': breed,
      'tagNumber': tagNumber,
    };
  }
}
