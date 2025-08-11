// lib/view_models/notifications_view_model.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_item.dart';
import '../services/notification_service.dart';

class NotificationsViewModel extends ChangeNotifier {
  final NotificationService service;
  final SupabaseClient supabase;
  NotificationsViewModel(this.service, this.supabase);

  List<NotificationItem> _items = [];
  bool _loading = false;
  RealtimeChannel? _channel;
  String? _userId;

  List<NotificationItem> get items => _items;
  bool get loading => _loading;
  int get unreadCount => _items.where((e) => !e.read).length;

  Future<void> init() async {
    final user = supabase.auth.currentUser;
    debugPrint('[NOTIF] init, user=${user?.id}');
    if (user == null) return;
    _userId = user.id;
    await refresh();
    _channel?.unsubscribe();
    _channel = service.subscribeUser(_userId!, () async {
      debugPrint('[NOTIF] onChange -> refreshing');
      await refresh();
    });
  }

  Future<void> refresh() async {
    if (_userId == null) return;
    _loading = true;
    notifyListeners();
    try {
      _items = await service.fetch(_userId!);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> markAllRead() async {
    if (_userId == null) return;
    await service.markAllRead(_userId!);
    _items = _items.map((e) => e.copyWith(read: true)).toList();
    notifyListeners();
  }

  Future<void> markRead(String id) async {
    await service.markRead(id);
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx != -1) {
      _items[idx] = _items[idx].copyWith(read: true);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}
