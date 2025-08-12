// lib/widgets/sidebar_menu.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'chat_screen.dart';
import '../views/livestock_screen/livestock_list_screen.dart';
import 'dashboard/dashboard_screen.dart';
import '../views/notifications/notifications_screen.dart';
import '../services/notification_service.dart';
import '../view_models/notifications_view_model.dart';
import 'widgets/notification_bell.dart';

class SidebarMenu extends StatefulWidget {
  const SidebarMenu({Key? key}) : super(key: key);

  static const IconData agriculture =
      IconData(0xe063, fontFamily: 'MaterialIcons');

  @override
  _SidebarMenuState createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  final supabase = Supabase.instance.client;

  String? email;
  String? username;
  String? avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() {
      email = user.email;
    });

    try {
      final profile = await supabase
          .from('profiles')
          .select('username, avatar_url')
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null) {
        setState(() {
          username = profile['username'] as String?;
          avatarUrl = profile['avatar_url'] as String?;
        });
        return;
      }
    } catch (error) {
      debugPrint('Could not load profiles table: $error');
    }

    setState(() {
      username = user.userMetadata?['username'] as String?;
      avatarUrl = user.userMetadata?['avatar_url'] as String?;
    });
  }

  Future<void> _openChat() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    final storageKey = user.id;
    final uuid = const Uuid();

    Navigator.pop(context);

    final prefs = await SharedPreferences.getInstance();
    String? saved = prefs.getString(storageKey);
    final sessionId = saved ?? uuid.v4();
    if (saved == null) await prefs.setString(storageKey, sessionId);

    Future.microtask(() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatScreen(sessionId: sessionId)),
      );
    });
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: iconColor ?? Colors.green, size: 26),
        title: Text(title, style: const TextStyle(fontSize: 15)),
        onTap: onTap,
        tileColor: Colors.grey[100],
        hoverColor: Colors.green[50],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String? publicAvatarUrl;
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      publicAvatarUrl =
          supabase.storage.from('avatars').getPublicUrl(avatarUrl!);
    }

    return ChangeNotifierProvider<NotificationsViewModel>(
      create: (_) {
        final vm = NotificationsViewModel(
          NotificationService(supabase),
          supabase,
        );
        vm.init();
        return vm;
      },
      child: Builder(builder: (context) {
        final vm = context.watch<NotificationsViewModel>();

        return Drawer(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 40, bottom: 20, left: 16, right: 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green, Colors.lightGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      backgroundImage: (publicAvatarUrl != null &&
                              publicAvatarUrl.isNotEmpty)
                          ? NetworkImage(publicAvatarUrl)
                          : null,
                      child: (publicAvatarUrl == null || publicAvatarUrl.isEmpty)
                          ? const Icon(Icons.person, size: 40, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (username != null)
                            Text(
                              username!,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          if (email != null)
                            Text(
                              email!,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                        ],
                      ),
                    ),
                    NotificationBell(
                      count: vm.unreadCount,
                      onPressed: () {
                        Navigator.pop(context);
                        Future.microtask(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ChangeNotifierProvider<NotificationsViewModel>(
                                create: (ctx) => NotificationsViewModel(
                                  NotificationService(Supabase.instance.client),
                                  Supabase.instance.client,
                                )..init(),
                                child: const NotificationsScreen(),
                              ),
                            ),
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Menu items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildMenuItem(
                      icon: Icons.home,
                      title: 'Dashboard',
                      onTap: () {
                        Navigator.pop(context);
                        Future.microtask(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const DashboardScreen()),
                          );
                        });
                      },
                    ),
                    _buildMenuItem(
                      icon: SidebarMenu.agriculture,
                      title: 'Livestocks',
                      onTap: () {
                        Navigator.pop(context);
                        Future.microtask(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LivestockListScreen()),
                          );
                        });
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.chat_rounded,
                      title: 'AgriVet AI assistance',
                      onTap: _openChat,
                    ),
                    const Divider(),
                    _buildMenuItem(
                      icon: Icons.logout,
                      iconColor: Colors.red,
                      title: 'Logout',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text("Logout"),
                            content: const Text("Are you sure you want to logout?"),
                            actions: [
                              TextButton(
                                child: const Text("Cancel"),
                                onPressed: () => Navigator.pop(dialogContext),
                              ),
                              TextButton(
                                child: const Text("Logout"),
                                onPressed: () async {
                                  await supabase.auth.signOut();
                                  if (context.mounted) {
                                    Navigator.pop(dialogContext);
                                    Navigator.pop(context);
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/signin',
                                      (route) => false,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
