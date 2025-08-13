import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  
  // Lazy loading variables
  static int numberOfTransactions = 0;
  static List<Map<String, dynamic>> currentTransactions = [];
  static bool loading = false;
  static bool _initialized = false;
  static bool hasMoreTransactions = true;
  static int _currentPage = 0;
  static const int _pageSize = 20;

  // Check if data has been loaded
  static bool get isInitialized => _initialized;
  static bool get isLoadingMore => loading;
  static bool get canLoadMore => hasMoreTransactions && !loading;

  // Authentication methods
  static User? get currentUser => _supabase.auth.currentUser;
  static bool get isAuthenticated => currentUser != null;

  // Sign up with email and password
  static Future<AuthResponse> signUp(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      // Since email confirmation is disabled, user should be automatically signed in
      if (response.user != null && response.session != null) {
        print('Sign up successful, user automatically signed in');
        return response;
      } else if (response.user != null) {
        print('Sign up successful, but no session created. Attempting auto sign-in...');
        
        // Try to sign in immediately after signup to bypass email confirmation
        try {
          final signInResponse = await _supabase.auth.signInWithPassword(
            email: email,
            password: password,
          );
          print('Auto sign-in successful after signup');
          return signInResponse;
        } catch (signInError) {
          print('Auto sign-in failed: $signInError');
          
          // If auto sign-in fails due to email confirmation, try to handle it
          if (signInError.toString().contains('email_not_confirmed')) {
            print('Email confirmation required. Attempting to handle...');
            
            // Wait a moment and try again (sometimes Supabase needs a moment to process)
            await Future.delayed(Duration(seconds: 2));
            
            try {
              final retrySignIn = await _supabase.auth.signInWithPassword(
                email: email,
                password: password,
              );
              print('Retry sign-in successful');
              return retrySignIn;
            } catch (retryError) {
              print('Retry sign-in failed: $retryError');
              // Return the original signup response and let the user handle it
              return response;
            }
          }
          
          // Return the original signup response
          return response;
        }
      }
      
      return response;
    } catch (error) {
      print('Error during sign up: $error');
      rethrow;
    }
  }

  // Sign in with email and password
  static Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (error) {
      print('Error during sign in: $error');
      
      // Handle email confirmation error for existing users
      if (error.toString().contains('email_not_confirmed')) {
        print('Email not confirmed for existing user. Attempting to handle...');
        
        // Try to resend confirmation or handle the issue
        try {
          // Wait a moment and try again (sometimes Supabase needs time to process)
          await Future.delayed(Duration(seconds: 2));
          
          final retryResponse = await _supabase.auth.signInWithPassword(
            email: email,
            password: password,
          );
          print('Retry sign-in successful after email confirmation issue');
          return retryResponse;
        } catch (retryError) {
          print('Retry sign-in failed: $retryError');
          
          // If retry fails, provide a helpful error message
          if (retryError.toString().contains('email_not_confirmed')) {
            throw Exception('Email confirmation required. Please check your email and click the confirmation link, or contact support to disable email confirmation for your account.');
          }
          
          rethrow;
        }
      }
      
      rethrow;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      // Clear local data
      currentTransactions.clear();
      numberOfTransactions = 0;
      _initialized = false;
    } catch (error) {
      print('Error during sign out: $error');
      rethrow;
    }
  }

  // Get current session
  static Session? get currentSession => _supabase.auth.currentSession;

  // Listen to auth state changes
  static Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Resend confirmation email (useful for existing users with email confirmation issues)
  static Future<void> resendConfirmationEmail(String email) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );
      print('Confirmation email resent to: $email');
    } catch (error) {
      print('Error resending confirmation email: $error');
      rethrow;
    }
  }

  // Initial load of transactions (first page)
  static Future<void> loadTransactions() async {
    if (_initialized && !loading) {
      // Data already loaded and not currently loading, return early
      return;
    }
    
    loading = true;
    _currentPage = 0;
    hasMoreTransactions = true;
    
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to load transactions');
      }

      final response = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', user.id) // Only load user's transactions
          .order('created_at', ascending: false)
          .range(_currentPage * _pageSize, (_currentPage + 1) * _pageSize - 1);
      
      if (response != null) {
        currentTransactions = List<Map<String, dynamic>>.from(response);
        numberOfTransactions = currentTransactions.length;
        
        // Check if we have more data
        hasMoreTransactions = response.length == _pageSize;
        _currentPage++;
      } else {
        currentTransactions = [];
        numberOfTransactions = 0;
        hasMoreTransactions = false;
      }
      _initialized = true;
    } catch (error) {
      print('Error loading transactions: $error');
      // If there's an error (like table doesn't exist), initialize with empty data
      currentTransactions = [];
      numberOfTransactions = 0;
      hasMoreTransactions = false;
      _initialized = true;
    } finally {
      loading = false;
    }
  }

  // Load more transactions (next page)
  static Future<void> loadMoreTransactions() async {
    if (!hasMoreTransactions || loading) {
      return;
    }
    
    loading = true;
    
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to load transactions');
      }

      final response = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', user.id) // Only load user's transactions
          .order('created_at', ascending: false)
          .range(_currentPage * _pageSize, (_currentPage + 1) * _pageSize - 1);
      
      if (response != null && response.isNotEmpty) {
        // Append new transactions to existing list
        currentTransactions.addAll(List<Map<String, dynamic>>.from(response));
        numberOfTransactions = currentTransactions.length;
        
        // Check if we have more data
        hasMoreTransactions = response.length == _pageSize;
        _currentPage++;
      } else {
        hasMoreTransactions = false;
      }
    } catch (error) {
      print('Error loading more transactions: $error');
      hasMoreTransactions = false;
    } finally {
      loading = false;
    }
  }

  // Reset pagination (useful for refresh)
  static void resetPagination() {
    _currentPage = 0;
    hasMoreTransactions = true;
    currentTransactions.clear();
    numberOfTransactions = 0;
    _initialized = false;
  }

  // insert a new transaction
  static Future<void> insert(String name, String amount, bool isIncome) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to add transactions');
      }

      final response = await _supabase
          .from('transactions')
          .insert({
            'name': name,
            'amount': double.parse(amount),
            'type': isIncome ? 'income' : 'expense',
            'user_id': user.id, // Add user ID to transaction
          })
          .select();
      
      if (response != null && response.isNotEmpty) {
        currentTransactions.insert(0, response[0]);
        numberOfTransactions++;
      }
    } catch (error) {
      print('Error inserting transaction: $error');
      // If insert fails, we might need to create the table
      print('Make sure you have run the SQL schema in your Supabase dashboard');
      rethrow;
    }
  }

  // CALCULATE THE TOTAL INCOME!
  static double calculateIncome() {
    try {
      final user = currentUser;
      if (user == null) return 0.0;

      double totalIncome = 0;
      for (int i = 0; i < currentTransactions.length; i++) {
        if (currentTransactions[i]['type'] == 'income' && 
            currentTransactions[i]['user_id'] == user.id) {
          totalIncome += (currentTransactions[i]['amount'] as num).toDouble();
        }
      }
      return totalIncome;
    } catch (e) {
      print('Error calculating income: $e');
      return 0.0;
    }
  }

  // CALCULATE THE TOTAL EXPENSE!
  static double calculateExpense() {
    try {
      final user = currentUser;
      if (user == null) return 0.0;

      double totalExpense = 0;
      for (int i = 0; i < currentTransactions.length; i++) {
        if (currentTransactions[i]['type'] == 'expense' && 
            currentTransactions[i]['user_id'] == user.id) {
          totalExpense += (currentTransactions[i]['amount'] as num).toDouble();
        }
      }
      return totalExpense;
    } catch (e) {
      print('Error calculating expense: $e');
      return 0.0;
    }
  }

  // delete a transaction
  static Future<void> deleteTransaction(String id) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to delete transactions');
      }

      // Verify the transaction belongs to the current user
      final transaction = currentTransactions.firstWhere(
        (tx) => tx['id'] == id,
        orElse: () => throw Exception('Transaction not found'),
      );

      if (transaction['user_id'] != user.id) {
        throw Exception('You can only delete your own transactions');
      }

      await _supabase
          .from('transactions')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id); // Ensure user can only delete their own transactions
      
      currentTransactions.removeWhere((transaction) => transaction['id'] == id);
      numberOfTransactions--;
    } catch (error) {
      print('Error deleting transaction: $error');
      rethrow;
    }
  }
} 