import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/models/transaction.dart';
import 'package:my_app/services/firebase_service.dart';

class TransactionStorageService {
  static String _key() {
    if (!FirebaseService.isAvailable) return 'app_transactions_anon';
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid == null ? 'app_transactions_anon' : 'app_transactions_$uid';
  }

  static Future<List<AppTransaction>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key());
    if (json == null) return AppTransaction.defaults;
    return AppTransaction.decodeList(json);
  }

  static Future<void> saveTransactions(
      List<AppTransaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(), AppTransaction.encodeList(transactions));
  }
}
