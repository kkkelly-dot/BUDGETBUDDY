import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  final VoidCallback onSignIn;
  final VoidCallback onSignUp;

  const LandingPage({
    Key? key,
    required this.onSignIn,
    required this.onSignUp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo (replace with your own if available)
              Icon(Icons.account_balance_wallet, size: 80, color: Colors.blue[700]),
              SizedBox(height: 24),
              Text(
                'BudgetBuddy',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Track your spending, grow your savings.',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: onSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  minimumSize: Size(double.infinity, 48),
                ),
                child: Text('Sign In', style: TextStyle(fontSize: 18)),
              ),
              SizedBox(height: 16),
              OutlinedButton(
                onPressed: onSignUp,
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                  side: BorderSide(color: Colors.blue[700]!),
                ),
                child: Text('Sign Up', style: TextStyle(fontSize: 18, color: Colors.blue[700])),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 