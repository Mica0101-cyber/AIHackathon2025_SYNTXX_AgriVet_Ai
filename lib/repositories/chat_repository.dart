// lib/repositories/chat_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message.dart';

class ChatRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Ensures that a session row exists for this sessionId (upsert by id).
  Future<void> _ensureSessionExists(String sessionId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user; cannot create chat session.');
    }

    await _supabase.from('chat_sessions').upsert(
      [
        {
          'id': sessionId,
          'user_id': user.id,
        }
      ],
      onConflict: 'id', // ← use a single string, not a list
    );
  }

  /// Fetches all messages for a given session ID, ordered by time.
  Future<List<Message>> fetchMessages(String sessionId) async {
    await _ensureSessionExists(sessionId);

    final res = await _supabase
        .from('messages')
        .select()
        .eq('session_id', sessionId)
        .order('emitted_at', ascending: true);

    return (res as List)
        .map((m) => Message.fromMap(m as Map<String, dynamic>))
        .toList();
  }

  /// Inserts one message into Supabase.
  Future<void> insertMessage(String sessionId, Message msg) async {
    await _ensureSessionExists(sessionId);

    final payload = <String, dynamic>{
      'session_id': sessionId,
      'role': msg.role,
      'content': msg.content,
      'emitted_at': (msg.emittedAt ?? DateTime.now()).toIso8601String(),
      if (msg.embedding != null) 'embedding': msg.embedding,
    };

    await _supabase.from('messages').insert(payload);
  }
}
