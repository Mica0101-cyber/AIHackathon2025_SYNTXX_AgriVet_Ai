import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../views/auth_screen.dart';
import '../views/dashboard/dashboard_screen.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;

        // Also check existing session on first load
        final existingSession = Supabase.instance.client.auth.currentSession;

        if (session != null || existingSession != null) {
          return const DashboardScreen();
        }
        return const AuthScreen();
      },
    );
  }
}