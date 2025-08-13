abstract class DataService {
  static int numberOfTransactions = 0;
  static List<Map<String, dynamic>> currentTransactions = [];
  static bool loading = true;

  static Future<void> init();
  static Future<void> loadTransactions();
  static Future<void> insert(String name, String amount, bool isIncome);
  static double calculateIncome();
  static double calculateExpense();
  static Future<void> deleteTransaction(String id);
} 