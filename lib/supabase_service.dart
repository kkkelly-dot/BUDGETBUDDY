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
      final response = await _supabase
          .from('transactions')
          .select()
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
      final response = await _supabase
          .from('transactions')
          .select()
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
      final response = await _supabase
          .from('transactions')
          .insert({
            'name': name,
            'amount': double.parse(amount),
            'type': isIncome ? 'income' : 'expense',
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
    }
  }

  // CALCULATE THE TOTAL INCOME!
  static double calculateIncome() {
    double totalIncome = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i]['type'] == 'income') {
        totalIncome += (currentTransactions[i]['amount'] as num).toDouble();
      }
    }
    return totalIncome;
  }

  // CALCULATE THE TOTAL EXPENSE!
  static double calculateExpense() {
    double totalExpense = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i]['type'] == 'expense') {
        totalExpense += (currentTransactions[i]['amount'] as num).toDouble();
      }
    }
    return totalExpense;
  }

  // delete a transaction
  static Future<void> deleteTransaction(String id) async {
    try {
      await _supabase
          .from('transactions')
          .delete()
          .eq('id', id);
      
      currentTransactions.removeWhere((transaction) => transaction['id'] == id);
      numberOfTransactions--;
    } catch (error) {
      print('Error deleting transaction: $error');
    }
  }
} 