class Contact {
  final int? id;
  final String name;
  final String phone;
  final String email;

  Contact({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
  });

  // Convert a map from Supabase to a Contact object
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
    );
  }

  // Convert a Contact object to a map for insertion/updating
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
    };
  }
}
