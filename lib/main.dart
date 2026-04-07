import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import 'view_models/contact_view_model.dart';
import 'view_models/livestock_viewmodel.dart';
import 'view_models/feed_records_view_model.dart';
import 'view_models/notifications_view_model.dart';
import 'view_models/weight_records_view_model.dart';
import 'view_models/health_record.dart';

import 'services/notification_service.dart';
import 'services/auth_service.dart';

import 'routes/app_router.dart';
import 'views/auth_screen.dart';
import 'views/dashboard/dashboard_screen.dart';
import 'views/chat_screen.dart';
import 'views/contacts_old/contact_list_screen.dart';
import 'views/contacts_old/add_contact_screen.dart';
import 'views/livestock_screen/livestock_list_screen.dart';
import 'views/livestock_screen/add_livestock_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zicujgizvwslzhzfxknz.supabase.co',
    anonKey: 'sb_publishable_nR0i8BpAzsuGIJATOsPFhg_Qfl_IABp',
  );

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => Supabase.instance.client),
        Provider(create: (_) => AuthService()),
        ProxyProvider<SupabaseClient, NotificationService>(
          update: (_, supabase, __) => NotificationService(supabase),
        ),
        ChangeNotifierProvider(create: (_) => ContactViewModel()),
        ChangeNotifierProvider(create: (_) => LivestockViewModel()),
        ChangeNotifierProvider(create: (_) => FeedRecordsViewModel()),
        ChangeNotifierProvider(create: (_) => HealthRecordsViewModel()),
        ChangeNotifierProvider<NotificationsViewModel>(
          create: (ctx) => NotificationsViewModel(
            ctx.read<NotificationService>(),
            ctx.read<SupabaseClient>(),
          ),
        ),
        ChangeNotifierProvider<WeightRecordsViewModel>(
          create: (ctx) => WeightRecordsViewModel(
            supabase: ctx.read<SupabaseClient>(),
            notifications: ctx.read<NotificationService>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agri-Wais',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      // ✅ Only ONE MaterialApp, all routes defined here
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/signin': (context) => const AuthScreen(),
        '/phonebook': (context) => const ContactListScreen(),
        '/addContact': (context) => const AddContactScreen(),
        '/chatScreen': (context) => const ChatScreen(),
        '/livestockList': (context) => const LivestockListScreen(),
        '/addLivestock': (context) => const AddLiveStockScreen(),
      },
      // ✅ AppRouter just returns a widget, no more nested MaterialApp
      home: const AppRouter(),
    );
  }
}