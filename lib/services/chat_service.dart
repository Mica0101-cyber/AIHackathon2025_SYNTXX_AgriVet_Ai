// lib/services/chat_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ChatService {
  final String endpoint =
      'https://agrivet-api-989999017956.asia-southeast1.run.app/chat';

  /// Sends the full message history, returns the assistant’s reply.
  Future<String> sendChat({
    required String sessionId,
    required List<Message> messages,
  }) async {
    final bodyMap = {
      'session_id': sessionId, // required by backend
      'model': 'gpt-4o-mini',
      'filter_prompt': '''
            You are AgriVet AI, a LIVESTOCK VETERINARY expert dedicated to assisting 
            smallholder farmers. Your scope is livestock health, husbandry, biosecurity, 
            and veterinary treatments. Do NOT answer crops or plant-disease topics. 
            Provide clear, step-by-step, resource-efficient guidance that fits local conditions, 
            uses readily available tools and materials, and relies on evidence-based best practices. 
            If you are uncertain or the question is outside livestock veterinary scope, say so gently, 
            recommend contacting a licensed livestock veterinarian when appropriate, and DO NOT include any URLs.
      ''',
      'messages': messages.map((m) => m.toJson()).toList(),
      'phase': 'auto',
      // Omit use_serpapi so the server applies its own policy (forces ON in diagnose mode).
      // 'use_serpapi': null, // intentionally omitted
    };

    final uri = Uri.parse(endpoint);

    http.Response res;
    try {
      // Optional: add a client-side timeout (e.g., 30s)
      res = await http
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(bodyMap))
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw Exception('Network error contacting AgriVet service: $e');
    }

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return (data['reply'] as String?) ?? 'No reply.';
    }

    // Surface server error details when possible
    try {
      final err = jsonDecode(res.body);
      throw Exception('Failed to get reply (${res.statusCode}): $err');
    } catch (_) {
      throw Exception('Failed to get reply (${res.statusCode}): ${res.body}');
    }
  }
}
