import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../view_models/contact_view_model.dart';
import '../view_models/livestock_viewmodel.dart';
import '../view_models/feed_records_view_model.dart';
import '../view_models/notifications_view_model.dart';
import '../view_models/weight_records_view_model.dart';
import '../services/notification_service.dart';
import '../routes/app_router.dart'; // Assume you have a simple routing setup
import '../view_models/health_record.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with your project credentials
  await Supabase.initialize(
    url: 'https://fxldxsnxezsfdiiioldd.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ4bGR4c254ZXpzZmRpaWlvbGRkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQyNjM2MzMsImV4cCI6MjA2OTgzOTYzM30.s2lb8h-S0i5rtzjXjctPoRNAfJpnWI8CYJYVVKEyQnI',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ContactViewModel()),
        ChangeNotifierProvider(create: (_) => LivestockViewModel()),
        ChangeNotifierProvider(create: (_) => FeedRecordsViewModel()),
        ChangeNotifierProvider(create: (_) => HealthRecordsViewModel()),
        Provider(create: (_) => Supabase.instance.client),
        ProxyProvider<SupabaseClient, NotificationService>(
          update: (_, supabase, __) => NotificationService(supabase),
        ),
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
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phonebook App',
      theme: ThemeData(primarySwatch: Colors.blue),
      // A simple router can decide whether to show an authentication screen or the phonebook
      home: const AppRouter(),
    );
  }
}
