import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService {
  // Sign up with email and password
  static Future<AuthResponse> signUp(String email, String password) async {
    try {
      print('AuthService: Attempting sign up for $email');
      final response = await SupabaseService.signUp(email, password);
      print('AuthService: Sign up successful for $email');
      return response;
    } catch (error) {
      print('AuthService signUp error: $error');
      rethrow;
    }
  }

  // Sign in with email and password
  static Future<AuthResponse> signIn(String email, String password) async {
    try {
      print('AuthService: Attempting sign in for $email');
      final response = await SupabaseService.signIn(email, password);
      print('AuthService: Sign in successful for $email');
      return response;
    } catch (error) {
      print('AuthService signIn error: $error');
      rethrow;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      print('AuthService: Attempting sign out');
      await SupabaseService.signOut();
      print('AuthService: Sign out successful');
    } catch (error) {
      print('AuthService signOut error: $error');
      rethrow;
    }
  }

  // Get current user
  static User? get currentUser => SupabaseService.currentUser;

  // Check if user is authenticated
  static bool get isAuthenticated => SupabaseService.isAuthenticated;

  // Get current session
  static Session? get currentSession => SupabaseService.currentSession;

  // Listen to auth state changes
  static Stream<AuthState> get authStateChanges => SupabaseService.authStateChanges;

  // Get user email
  static String? get userEmail => currentUser?.email;

  // Get user ID
  static String? get userId => currentUser?.id;
}
