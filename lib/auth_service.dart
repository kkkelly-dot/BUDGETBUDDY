import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService {
  // Sign up with email and password
  static Future<AuthResponse> signUp(String email, String password, {String? name}) async {
    try {
      print('AuthService: Attempting sign up for $email with name: "$name"');
      final response = await SupabaseService.signUp(email, password, name: name);
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

  // Get user display name
  static String get userDisplayName {
    final user = currentUser;
    print('AuthService: Getting display name for user: $user');
    
    if (user == null) {
      print('AuthService: No current user, returning Guest User');
      return 'Guest User';
    }
    
    // Try to get name from user metadata first
    final metadata = user.userMetadata;
    print('AuthService: User metadata: $metadata');
    
    if (metadata != null && metadata['full_name'] != null) {
      print('AuthService: Found full_name in metadata: ${metadata['full_name']}');
      return metadata['full_name'];
    }
    
    // Try to get name from user metadata with different key
    if (metadata != null && metadata['name'] != null) {
      print('AuthService: Found name in metadata: ${metadata['name']}');
      return metadata['name'];
    }
    
    // If no name in metadata, use email prefix as display name
    if (user.email != null) {
      final emailParts = user.email!.split('@');
      if (emailParts.isNotEmpty) {
        // Capitalize first letter and make it look like a name
        final emailPrefix = emailParts[0];
        if (emailPrefix.isNotEmpty) {
          final displayName = emailPrefix[0].toUpperCase() + emailPrefix.substring(1);
          print('AuthService: Using email prefix as display name: $displayName');
          return displayName;
        }
      }
    }
    
    // Fallback to generic name
    print('AuthService: No name found, using fallback: BudgetBuddy User');
    return 'BudgetBuddy User';
  }
}
