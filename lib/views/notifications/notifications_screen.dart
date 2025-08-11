// lib/views/notifications/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/notifications_view_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInit) {
      _didInit = true;
      // kick off initial fetch + realtime subscribe
      Future.microtask(() => context.read<NotificationsViewModel>().init());
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationsViewModel>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: vm.unreadCount == 0 ? null : vm.markAllRead,
            child: const Text('Mark all as read'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: vm.refresh,
        child: vm.loading && vm.items.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: vm.items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final n = vm.items[i];
                  return ListTile(
                    title: Text(
                      n.title,
                      style: TextStyle(
                        fontWeight:
                            n.read ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(n.body,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: n.read
                        ? null
                        : const Icon(Icons.fiber_manual_record, size: 10),
                    onTap: () => vm.markRead(n.id),
                  );
                },
              ),
      ),
    );
  }
}
