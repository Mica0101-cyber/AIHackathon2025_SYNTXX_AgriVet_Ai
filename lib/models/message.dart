// lib/models/message.dart

class Message {
  final String role;
  final String content;
  final DateTime? emittedAt; // when the message was sent/received
  final List<double>? embedding; // optional 1536-dim vector

  Message({
    required this.role,
    required this.content,
    this.emittedAt,
    this.embedding,
  });

  /// Used when calling your OpenAI HTTP endpoint.
  /// Only includes role & content.
  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };

  /// Used when inserting into Supabase.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'role': role,
      'content': content,
      'emitted_at': (emittedAt ?? DateTime.now()).toIso8601String(),
    };
    if (embedding != null) {
      map['embedding'] = embedding;
    }
    return map;
  }

  /// For decoding your HTTP response (OpenAI reply).
  factory Message.fromJson(Map<String, dynamic> json) => Message(
        role: json['role'] as String,
        content: json['content'] as String,
      );

  /// For decoding rows fetched from Supabase.
  factory Message.fromMap(Map<String, dynamic> map) {
    List<double>? vec;
    if (map['embedding'] != null) {
      vec = (map['embedding'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList();
    }

    return Message(
      role: map['role'] as String,
      content: map['content'] as String,
      emittedAt: map['emitted_at'] != null
          ? DateTime.parse(map['emitted_at'] as String)
          : null,
      embedding: vec,
    );
  }
}
