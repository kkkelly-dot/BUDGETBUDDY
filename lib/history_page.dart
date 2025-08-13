import 'package:flutter/material.dart';
import 'supabase_service.dart';
import 'mock_service.dart';
import 'config.dart';

class HistoryPage extends StatefulWidget {
  final VoidCallback? onBack;
  
  const HistoryPage({Key? key, this.onBack}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime? _selectedDate;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _isInitialLoading = true;
  String? _errorMessage;
  
  List<Map<String, dynamic>> get _allTransactions {
    try {
      if (Config.supabaseUrl == 'https://ledwqyxnksayvphwqdyz.supabase.co' && 
          Config.supabaseAnonKey == 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxlZHdxeXhua3NheXZwaHdxZHl6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMzMTg3MDYsImV4cCI6MjA2ODg5NDcwNn0.Ab7g13q_H-gMb10n8IqHMaygc-q7VY-0gm3LJ3e71oU') {
        return SupabaseService.currentTransactions;
      } else {
        return MockService.currentTransactions;
      }
    } catch (e) {
      print('Error getting transactions: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_selectedDate == null) return _allTransactions;
    
    return _allTransactions.where((tx) {
      try {
        final date = DateTime.tryParse(tx['created_at'].toString());
        if (date == null) return false;
        
        return date.year == _selectedDate!.year &&
               date.month == _selectedDate!.month &&
               date.day == _selectedDate!.day;
      } catch (e) {
        print('Error parsing date: $e');
        return false;
      }
    }).toList();
  }

  double get _incomeTotal {
    try {
      return _filteredTransactions
          .where((tx) => tx['type'] == 'income')
          .fold(0.0, (sum, tx) => sum + (tx['amount'] as num).toDouble());
    } catch (e) {
      print('Error calculating income: $e');
      return 0.0;
    }
  }

  double get _expenseTotal {
    try {
      return _filteredTransactions
          .where((tx) => tx['type'] == 'expense')
          .fold(0.0, (sum, tx) => sum + (tx['amount'] as num).toDouble());
    } catch (e) {
      print('Error calculating expense: $e');
      return 0.0;
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialTransactions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialTransactions() async {
    setState(() {
      _isInitialLoading = true;
      _errorMessage = null;
    });

    try {
      if (Config.supabaseUrl != 'YOUR_SUPABASE_URL' && 
          Config.supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY') {
        await SupabaseService.loadTransactions();
      } else {
        await MockService.init();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load transactions: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreTransactions();
    }
  }

  Future<void> _loadMoreTransactions() async {
    if (_isLoadingMore || !SupabaseService.canLoadMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      await SupabaseService.loadMoreTransactions();
    } catch (e) {
      print('Error loading more transactions: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _refreshTransactions() async {
    try {
      if (Config.supabaseUrl != 'YOUR_SUPABASE_URL' && 
          Config.supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY') {
        SupabaseService.resetPagination();
        await SupabaseService.loadTransactions();
      } else {
        await MockService.init();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to refresh: ${e.toString()}';
      });
    }
    
    if (mounted) setState(() {});
  }

  String _formatDate(dynamic dateValue) {
    try {
      if (dateValue is String) {
        final date = DateTime.tryParse(dateValue);
        if (date != null) {
          return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
        }
      } else if (dateValue is DateTime) {
        return '${dateValue.day.toString().padLeft(2, '0')}/${dateValue.month.toString().padLeft(2, '0')}/${dateValue.year}';
      }
      return 'Unknown date';
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _formatAmount(dynamic amount) {
    try {
      if (amount is num) {
        return amount.toStringAsFixed(2);
      } else if (amount is String) {
        final parsed = double.tryParse(amount);
        if (parsed != null) {
          return parsed.toStringAsFixed(2);
        }
      }
      return '0.00';
    } catch (e) {
      return '0.00';
    }
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final isIncome = transaction['type'] == 'income';
    final amount = _formatAmount(transaction['amount']);
    final date = _formatDate(transaction['created_at']);
    final name = transaction['name']?.toString() ?? 'Unnamed Transaction';
    final id = transaction['id']?.toString() ?? '';

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isIncome ? Colors.blue.shade100 : Colors.red.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: isIncome ? Colors.blue.shade700 : Colors.red.shade700,
            size: 24,
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          date,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              (isIncome ? '+' : '-') + 'GH₵' + amount,
              style: TextStyle(
                color: isIncome ? Colors.blue.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (id.isNotEmpty)
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
                onPressed: () => _showDeleteDialog(transaction),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> transaction) {
    final name = transaction['name']?.toString() ?? 'this transaction';
    final id = transaction['id']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Transaction'),
          content: Text('Are you sure you want to delete "$name"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteTransaction(id);
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTransaction(String id) async {
    try {
      if (Config.supabaseUrl != 'YOUR_SUPABASE_URL' && 
          Config.supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY') {
        await SupabaseService.deleteTransaction(id);
      } else {
        await MockService.deleteTransaction(id);
      }
      setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete transaction: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _selectedDate != null 
                ? 'Try selecting a different date or clear the filter'
                : 'Add your first transaction to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.red.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Failed to load transactions',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadInitialTransactions,
            child: Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            tooltip: 'Pick Date',
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
          ),
          if (_selectedDate != null)
            IconButton(
              icon: Icon(Icons.clear),
              tooltip: 'Clear Date Filter',
              onPressed: () => setState(() => _selectedDate = null),
            ),
        ],
      ),
      body: _isInitialLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.blue.shade600),
                  SizedBox(height: 16),
                  Text('Loading transactions...'),
                ],
              ),
            )
          : _errorMessage != null
              ? _buildErrorState()
              : Column(
                  children: [
                    // Summary Cards
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(child: _SummaryCard(
                            label: 'Income',
                            value: _incomeTotal,
                            color: Colors.blue,
                          )),
                          SizedBox(width: 12),
                          Expanded(child: _SummaryCard(
                            label: 'Expense',
                            value: _expenseTotal,
                            color: Colors.red,
                          )),
                          SizedBox(width: 12),
                          Expanded(child: _SummaryCard(
                            label: 'Balance',
                            value: _incomeTotal - _expenseTotal,
                            color: _incomeTotal - _expenseTotal >= 0 ? Colors.blue : Colors.orange,
                          )),
                        ],
                      ),
                    ),
                    
                    // Transactions List
                    Expanded(
                      child: _filteredTransactions.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _refreshTransactions,
                              child: ListView.builder(
                                controller: _scrollController,
                                itemCount: _filteredTransactions.length + 
                                    (SupabaseService.canLoadMore && !_isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == _filteredTransactions.length) {
                                    return Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                  return _buildTransactionItem(_filteredTransactions[index]);
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'GH₵${value.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                                              color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 