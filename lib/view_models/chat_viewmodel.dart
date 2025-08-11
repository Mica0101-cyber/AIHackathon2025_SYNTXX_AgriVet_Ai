// lib/view_models/chat_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import '../repositories/chat_repository.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatService _chatService;
  final ChatRepository _chatRepo;
  final String sessionId;

  ChatViewModel({
    String? sessionId,
    ChatService? chatService,
    ChatRepository? chatRepo,
  })  : _chatService = chatService ?? ChatService(),
        _chatRepo = chatRepo ?? ChatRepository(),
        sessionId = sessionId ?? const Uuid().v4() {
    _loadHistory();
  }

  final List<Message> _messages = [];
  bool _isLoading = false;

  List<Message> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  final List<String> _presetQuestions = [
    'Best feed for dairy cows?',
    'How to prevent mastitis in goats?',
  ];
  List<String> get presetQuestions => List.unmodifiable(_presetQuestions);

  Future<void> _loadHistory() async {
    _setLoading(true);

    // fetch any saved messages
    final history = await _chatRepo.fetchMessages(sessionId);

    if (history.isEmpty) {
      // first‐time session → add initial greeting
      final greeting = Message(
        role: 'assistant',
        content:
            '🌱 Hello! I’m your AgriVet assistant. How can I help you today?',
      );
      _messages.add(greeting);
      // persist greeting so it's in history next time
      await _chatRepo.insertMessage(sessionId, greeting);
    } else {
      _messages.addAll(history);
    }

    _setLoading(false);
  }

  Future<void> sendMessage(String content) async {
    final userMsg = Message(role: 'user', content: content);
    _addAndPersist(userMsg);

    _setLoading(true);
    try {
      final replyText = await _chatService.sendChat(
        sessionId: sessionId, // ← pass it through
        messages: _messages,
      );
      final assistantMsg = Message(role: 'assistant', content: replyText);
      _addAndPersist(assistantMsg);
    } catch (e) {
      final errorMsg = Message(
        role: 'assistant',
        content: 'Error: $e',
      );
      _addAndPersist(errorMsg);
    }
    _setLoading(false);
  }

  Future<void> sendPresetMessage(String content) => sendMessage(content);

  void _addAndPersist(Message msg) {
    _messages.add(msg);
    notifyListeners();
    _chatRepo.insertMessage(sessionId, msg);
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
