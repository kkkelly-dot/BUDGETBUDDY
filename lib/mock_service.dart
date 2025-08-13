class MockService {
  // some variables to keep track of..
  static int numberOfTransactions = 0;
  static List<Map<String, dynamic>> currentTransactions = [];
  static bool loading = false;

  // initialise the service
  static Future<void> init() async {
    // Add some sample data
    currentTransactions = [
      {
        'id': '1',
        'name': 'Salary',
        'amount': 5000.0,
        'type': 'income',
        'created_at': DateTime.now().subtract(Duration(days: 1)),
      },
      {
        'id': '2',
        'name': 'Groceries',
        'amount': 150.0,
        'type': 'expense',
        'created_at': DateTime.now().subtract(Duration(hours: 2)),
      },
      {
        'id': '3',
        'name': 'Freelance Work',
        'amount': 800.0,
        'type': 'income',
        'created_at': DateTime.now().subtract(Duration(hours: 1)),
      },
    ];
    numberOfTransactions = currentTransactions.length;
    loading = false;
  }

  // load existing transactions from the database
  static Future<void> loadTransactions() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));
    loading = false;
  }

  // insert a new transaction
  static Future<void> insert(String name, String amount, bool isIncome) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300));
    
    final newTransaction = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'amount': double.parse(amount),
      'type': isIncome ? 'income' : 'expense',
      'created_at': DateTime.now(),
    };
    
    currentTransactions.insert(0, newTransaction);
    numberOfTransactions++;
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
    await Future.delayed(Duration(milliseconds: 200));
    currentTransactions.removeWhere((transaction) => transaction['id'] == id);
    numberOfTransactions--;
  }
} 