import 'package:flutter/material.dart';
import 'package:phonebook_app/views/livestock_screen/add_livestock_screen.dart';
import 'package:phonebook_app/views/livestock_screen/weight_record/weight_records_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../views/auth_screen.dart';
import '../views/contacts_old/contact_list_screen.dart';
import '../views/contacts_old/add_contact_screen.dart';
import '../views/dashboard/dashboard_screen.dart';
import '../views/livestock_screen/livestock_list_screen.dart';
import '../views/chat_screen.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phonebook App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => AuthChecker(),
        '/signin': (context) => const AuthScreen(),
        '/phonebook': (context) => const ContactListScreen(), // no longer used
        '/addContact': (context) => const UserRegistrationScreen(), // no longer used
        '/dashboard': (context) => const DashboardScreen(),
        '/chatScreen': (context) => const ChatScreen(),
        '/livestockList': (context) => const LivestockListScreen(),
       '/addLivestock': (context) => const AddLiveStockScreen(),
        


      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: Center(child: Text('Page not found')),
        ),
      ),
    );
  }
}

class AuthChecker extends StatelessWidget {
  AuthChecker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      return const DashboardScreen();
    } else {
      return const AuthScreen();
    }
  }
}