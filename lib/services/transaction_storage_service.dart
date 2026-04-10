import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/models/transaction.dart';

class TransactionStorageService {
  static const _key = 'app_transactions';

  static Future<List<AppTransaction>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return AppTransaction.defaults;
    return AppTransaction.decodeList(json);
  }

  static Future<void> saveTransactions(
      List<AppTransaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, AppTransaction.encodeList(transactions));
  }
}
