import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'chat_screen.dart';
import '../views/livestock_screen/livestock_list_screen.dart';
import '../views/dashboard/dashboard_screen.dart';
import '../views/notifications/notifications_screen.dart';
import '../services/notification_service.dart';
import '../view_models/notifications_view_model.dart';
import '../views/widgets/notification_bell.dart';

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

  @override
  Widget build(BuildContext context) {
    String? publicAvatarUrl;
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      publicAvatarUrl =
          supabase.storage.from('avatars').getPublicUrl(avatarUrl!);
    }

    // Provide NotificationsViewModel scoped to this drawer (or lift to app root if used elsewhere).
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
          child: ListView(padding: EdgeInsets.zero, children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.grey),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: (publicAvatarUrl != null &&
                                publicAvatarUrl.isNotEmpty)
                            ? NetworkImage(publicAvatarUrl)
                            : null,
                        child:
                            (publicAvatarUrl == null || publicAvatarUrl.isEmpty)
                                ? const Icon(Icons.person,
                                    size: 36, color: Colors.grey)
                                : null,
                      ),
                      const Spacer(),
                      NotificationBell(
                        count: vm.unreadCount,
                        onPressed: () {
                          Navigator.pop(context);
                          Future.microtask(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChangeNotifierProvider<
                                    NotificationsViewModel>(
                                  create: (ctx) => NotificationsViewModel(
                                    NotificationService(
                                        Supabase.instance.client),
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
                  const SizedBox(height: 12),
                  if (username != null)
                    Text(
                      username!,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  if (email != null)
                    Text(
                      email!,
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Dashboard'),
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
            ListTile(
              leading: const Icon(SidebarMenu.agriculture),
              title: const Text('Livestocks'),
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
            // ListTile(
            //   leading: Stack(
            //     clipBehavior: Clip.none,
            //     children: [
            //       const Icon(Icons.notifications),
            //       if (vm.unreadCount > 0)
            //         Positioned(
            //           right: -2,
            //           top: -2,
            //           child: Container(
            //             padding: const EdgeInsets.symmetric(
            //                 horizontal: 5, vertical: 1),
            //             decoration: BoxDecoration(
            //               color: Theme.of(context).colorScheme.error,
            //               borderRadius: BorderRadius.circular(10),
            //             ),
            //             child: Text(
            //               vm.unreadCount > 99 ? '99+' : '${vm.unreadCount}',
            //               style: const TextStyle(
            //                   color: Colors.white, fontSize: 10),
            //             ),
            //           ),
            //         ),
            //     ],
            //   ),
            //   title: const Text('Notifications'),
            //   onTap: () {
            //     Navigator.pop(context);
            //     Future.microtask(() {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //             builder: (_) => const NotificationsScreen()),
            //       );
            //     });
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.pets),
              title: const Text('AgriVet AI assistance'),
              onTap: _openChat,
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
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
          ]),
        );
      }),
    );
  }
}
