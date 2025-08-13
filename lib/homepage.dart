import 'package:flutter/material.dart';
import 'supabase_service.dart';
import 'mock_service.dart';
import 'config.dart';
import 'loading_circle.dart';
import 'plus_button.dart';
import 'top_card.dart';
import 'transaction.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _textcontrollerAMOUNT = TextEditingController();
  final _textcontrollerITEM = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isIncome = false;

  void _enterTransaction() async {
    if (Config.supabaseUrl != 'YOUR_SUPABASE_URL' && Config.supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY') {
      await SupabaseService.insert(
        _textcontrollerITEM.text.trim(),
        _textcontrollerAMOUNT.text.trim(),
        _isIncome,
      );
    } else {
      await MockService.insert(
        _textcontrollerITEM.text.trim(),
        _textcontrollerAMOUNT.text.trim(),
        _isIncome,
      );
    }

    _textcontrollerITEM.clear();
    _textcontrollerAMOUNT.clear();
    setState(() {});
  }

  void _newTransaction() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return AlertDialog(
                title: Text('N E W  T R A N S A C T I O N'),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('Expense'),
                          Switch(
                            value: _isIncome,
                            onChanged: (newValue) {
                              setState(() {
                                _isIncome = newValue;
                              });
                            },
                          ),
                          Text('Income'),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                            child: Form(
                              key: _formKey,
                              child: TextFormField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Amount? (GH₵)',
                                ),
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Enter an amount';
                                  }
                                  return null;
                                },
                                controller: _textcontrollerAMOUNT,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'For what?',
                              ),
                              controller: _textcontrollerITEM,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  MaterialButton(
                    color: Colors.grey[600],
                    child:
                        Text('Cancel', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  MaterialButton(
                    color: Colors.grey[600],
                    child: Text('Enter', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _enterTransaction();
                        Navigator.of(context).pop();
                      }
                    },
                  )
                ],
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            SizedBox(height: 30),
            // Top summary: income/expense (simplified)
            FutureBuilder(
              future: Config.supabaseUrl != 'YOUR_SUPABASE_URL' && Config.supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY'
                  ? SupabaseService.loadTransactions()
                  : MockService.loadTransactions(),
              builder: (context, snapshot) {
                final loading = Config.supabaseUrl != 'YOUR_SUPABASE_URL' && Config.supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY'
                    ? SupabaseService.loading
                    : MockService.loading;
                
                if (loading) return LoadingCircle();

                final income = Config.supabaseUrl != 'YOUR_SUPABASE_URL' && Config.supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY'
                    ? SupabaseService.calculateIncome()
                    : MockService.calculateIncome();
                final expense = Config.supabaseUrl != 'YOUR_SUPABASE_URL' && Config.supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY'
                    ? SupabaseService.calculateExpense()
                    : MockService.calculateExpense();

                return TopNeuCard(
                  balance: (income - expense).toStringAsFixed(2),
                  income: income.toStringAsFixed(2),
                  expense: expense.toStringAsFixed(2),
                );
              },
            ),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder(
                future: Config.supabaseUrl != 'YOUR_SUPABASE_URL' && Config.supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY'
                    ? SupabaseService.loadTransactions()
                    : MockService.loadTransactions(),
                builder: (context, snapshot) {
                  final loading = Config.supabaseUrl != 'YOUR_SUPABASE_URL' && Config.supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY'
                      ? SupabaseService.loading
                      : MockService.loading;
                  
                  if (loading) return LoadingCircle();

                  final transactions = Config.supabaseUrl != 'YOUR_SUPABASE_URL' && Config.supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY'
                      ? SupabaseService.currentTransactions
                      : MockService.currentTransactions;

                  return ListView(
                    children: transactions.map((transaction) {
                      return MyTransaction(
                        transactionName: transaction['name'] ?? '',
                        money: (transaction['amount'] as num).toString(),
                        expenseOrIncome: transaction['type'] ?? '',
                        transactionId: transaction['id'] ?? '',
                        onDelete: () {
                          setState(() {
                            // This will trigger a rebuild and refresh the data
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            PlusButton(function: _newTransaction),
          ],
        ),
      ),
    );
  }
}
