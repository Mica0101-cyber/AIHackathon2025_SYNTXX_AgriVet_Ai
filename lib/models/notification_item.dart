// lib/models/notification_item.dart
class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;
  final String recipientId;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.read,
    required this.recipientId,
  });

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    final createdRaw = map['created_at'];
    final createdAt = createdRaw is String
        ? DateTime.parse(createdRaw)
        : (createdRaw is DateTime ? createdRaw : DateTime.now());

    return NotificationItem(
      id: map['id'].toString(),
      title: (map['title'] ?? '') as String,
      body: (map['body'] ?? '') as String,
      createdAt: createdAt,
      read: (map['read'] ?? false) as bool,
      recipientId: map['recipient_id'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'created_at': createdAt.toIso8601String(),
        'read': read,
        'recipient_id': recipientId,
      };

  NotificationItem copyWith({bool? read}) => NotificationItem(
        id: id,
        title: title,
        body: body,
        createdAt: createdAt,
        read: read ?? this.read,
        recipientId: recipientId,
      );
}
