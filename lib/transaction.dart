import 'package:flutter/material.dart';
import 'supabase_service.dart';
import 'mock_service.dart';
import 'config.dart';

class MyTransaction extends StatelessWidget {
  final String transactionName;
  final String money;
  final String expenseOrIncome;
  final String transactionId;
  final VoidCallback? onDelete;

  MyTransaction({
    required this.transactionName,
    required this.money,
    required this.expenseOrIncome,
    required this.transactionId,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.all(15),
          color: Colors.grey[100],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.grey[500]),
                    child: Center(
                      child: Icon(
                        Icons.attach_money_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(transactionName,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      )),
                ],
              ),
              Row(
                children: [
                  Text(
                    (expenseOrIncome == 'expense' ? '-' : '+') +
                        '\GH₵ ' +
                        money,
                    style: TextStyle(
                      //fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: expenseOrIncome == 'expense'
                          ? Colors.red
                          : Colors.blue,
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _showDeleteDialog(context),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.red[700],
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Transaction'),
          content: Text('Are you sure you want to delete "$transactionName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteTransaction();
                if (onDelete != null) {
                  onDelete!();
                }
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

  Future<void> _deleteTransaction() async {
    try {
      if (Config.supabaseUrl != 'YOUR_SUPABASE_URL' &&
          Config.supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY') {
        await SupabaseService.deleteTransaction(transactionId);
      } else {
        await MockService.deleteTransaction(transactionId);
      }
    } catch (error) {
      print('Error deleting transaction: $error');
    }
  }
}
