import 'package:flutter/material.dart';
import 'supabase_service.dart';
import 'mock_service.dart';
import 'config.dart';
import 'transaction.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime? _selectedDate;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  
  List<Map<String, dynamic>> get _allTransactions =>
      Config.supabaseUrl == 'https://ledwqyxnksayvphwqdyz.supabase.co' && Config.supabaseAnonKey == 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxlZHdxeXhua3NheXZwaHdxZHl6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMzMTg3MDYsImV4cCI6MjA2ODg5NDcwNn0.Ab7g13q_H-gMb10n8IqHMaygc-q7VY-0gm3LJ3e71oU'
          ? SupabaseService.currentTransactions
          : MockService.currentTransactions;

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_selectedDate == null) return _allTransactions;
    return _allTransactions.where((tx) {
      final date = DateTime.tryParse(tx['created_at'].toString());
      return date != null &&
          date.year == _selectedDate!.year &&
          date.month == _selectedDate!.month &&
          date.day == _selectedDate!.day;
    }).toList();
  }

  double get _incomeTotal => _filteredTransactions
      .where((tx) => tx['type'] == 'income')
      .fold(0.0, (sum, tx) => sum + (tx['amount'] as num).toDouble());
  double get _expenseTotal => _filteredTransactions
      .where((tx) => tx['type'] == 'expense')
      .fold(0.0, (sum, tx) => sum + (tx['amount'] as num).toDouble());

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

  void _loadInitialTransactions() async {
    if (Config.supabaseUrl != 'YOUR_SUPABASE_URL' && Config.supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY') {
      await SupabaseService.loadTransactions();
      if (mounted) setState(() {});
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreTransactions();
    }
  }

  void _loadMoreTransactions() async {
    if (_isLoadingMore || !SupabaseService.canLoadMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    await SupabaseService.loadMoreTransactions();
    
    if (mounted) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _refreshTransactions() async {
    if (Config.supabaseUrl != 'YOUR_SUPABASE_URL' && Config.supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY') {
      SupabaseService.resetPagination();
      await SupabaseService.loadTransactions();
      if (mounted) setState(() {});
    }
  }

  bool _shouldShowLoadingIndicator() {
    return _isLoadingMore || SupabaseService.canLoadMore;
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History'),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SummaryCard(label: 'Income', value: _incomeTotal),
                _SummaryCard(label: 'Expense', value: _expenseTotal),
                _SummaryCard(label: 'Balance', value: _incomeTotal - _expenseTotal),
              ],
            ),
          ),
          Expanded(
            child: _filteredTransactions.isEmpty
                ? Center(child: Text('No transactions found.'))
                : RefreshIndicator(
                    onRefresh: _refreshTransactions,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _filteredTransactions.length + (_shouldShowLoadingIndicator() ? 1 : 0),
                      itemBuilder: (context, i) {
                        // Show loading indicator at the bottom
                        if (i == _filteredTransactions.length) {
                          return _buildLoadingIndicator();
                        }
                        
                        final tx = _filteredTransactions[i];
                        final date = DateTime.tryParse(tx['created_at'].toString());
                        return ListTile(
                          leading: Icon(
                            tx['type'] == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
                            color: tx['type'] == 'income' ? Colors.green : Colors.red,
                          ),
                          title: Text(tx['name'] ?? ''),
                          subtitle: Text(date != null ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}' : ''),
                          trailing: Text(
                            (tx['type'] == 'expense' ? '-' : '+') + 'GH₵' + (tx['amount'] as num).toStringAsFixed(2),
                            style: TextStyle(
                              color: tx['type'] == 'income' ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
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
  const _SummaryCard({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            SizedBox(height: 4),
            Text('GH₵' + value.toStringAsFixed(2),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
} 