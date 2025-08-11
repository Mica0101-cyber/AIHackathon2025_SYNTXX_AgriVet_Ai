// lib/services/notification_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_item.dart';
import 'package:flutter/foundation.dart'; // Import this line

class NotificationService {
  final SupabaseClient supabase;
  NotificationService(this.supabase);

  /// Fetch newest-first, strongly typed (no runtime casts).
  Future<List<NotificationItem>> fetch(String userId) async {
    final rows = (await supabase
        .from('notifications')
        .select()
        .eq('recipient_id', userId)
        .order('created_at', ascending: false)) as List<dynamic>;

    return rows
        .map((row) => NotificationItem.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  /// Mark all unread as read for this user.
  Future<void> markAllRead(String userId) async {
    await supabase
        .from('notifications')
        .update({'read': true})
        .eq('recipient_id', userId)
        .eq('read', false);
  }

  /// Mark a single notification as read.
  Future<void> markRead(String id) async {
    await supabase.from('notifications').update({'read': true}).eq('id', id);
  }

  /// Create a notification. (Server will set created_at + id.)
  Future<void> create(
      {required String recipientId,
      required String title,
      required String body}) async {
    debugPrint('[NOTIF] create -> $recipientId | $title | $body');
    final res = await supabase.from('notifications').insert({
      'recipient_id': recipientId,
      'title': title,
      'body': body,
    });
    debugPrint('[NOTIF] insert done -> $res');
  }

  RealtimeChannel subscribeUser(String userId, void Function() onChange) {
    debugPrint('[NOTIF] subscribeUser($userId)');
    final channel = supabase.channel('public:notifications:user:$userId');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'notifications',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'recipient_id',
        value: userId,
      ),
      callback: (payload) {
        debugPrint(
            '[NOTIF] change: ${payload.eventType} -> ${payload.newRecord}');
        onChange();
      },
    );

    channel.subscribe((status, _) {
      debugPrint('[NOTIF] realtime status: $status'); // SUBSCRIBED expected
    });
    return channel;
  }
}
