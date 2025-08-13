abstract class DataService {
  int get numberOfTransactions;
  List<Map<String, dynamic>> get currentTransactions;
  bool get loading;

  Future<void> init();
  Future<void> loadTransactions();
  Future<void> insert(String name, String amount, bool isIncome);
  double calculateIncome();
  double calculateExpense();
  Future<void> deleteTransaction(String id);
} 