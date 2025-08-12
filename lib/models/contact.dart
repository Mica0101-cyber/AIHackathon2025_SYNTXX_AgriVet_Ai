class Contact {
  final int? id; // Supabase will auto-generate this
  final String name;
  final String phone;
  final String email;

  Contact({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
  });

  /// Convert a map from Supabase into a Contact object
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as int?,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
    );
  }

  /// Convert a Contact object into a map for Supabase insert/update
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      'email': email,
    };
  }
}
