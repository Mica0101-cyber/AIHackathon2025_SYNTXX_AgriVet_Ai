import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  // Get the initialized Supabase client
  final _supabase = Supabase.instance.client;

  // Sign Up a new user
  Future<AuthResponse> signUp(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  // Sign In an existing user
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Check if a user is currently logged in
  User? get currentUser => _supabase.auth.currentUser;
}