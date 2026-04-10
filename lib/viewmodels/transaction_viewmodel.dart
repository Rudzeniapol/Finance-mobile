import 'package:flutter/material.dart';
import 'package:my_app/models/transaction.dart';
import 'package:my_app/services/firebase_service.dart';
import 'package:my_app/services/transaction_storage_service.dart';

class TransactionViewModel extends ChangeNotifier {
  List<AppTransaction> _transactions = [];
  bool _isLoading = true;

  List<AppTransaction> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;

  TransactionViewModel() {
    loadTransactions();
  }

  // ── Load ─────────────────────────────────────────────────────────────────────

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    if (FirebaseService.isAvailable) {
      try {
        _transactions = await FirebaseService.loadTransactions();
        if (_transactions.isEmpty) {
          // First run with Firebase: seed with defaults and push them up
          for (final tx in AppTransaction.defaults) {
            await FirebaseService.saveTransaction(tx);
          }
          _transactions = AppTransaction.defaults;
        }
        await TransactionStorageService.saveTransactions(_transactions);
      } catch (_) {
        _transactions = await TransactionStorageService.loadTransactions();
      }
    } else {
      _transactions = await TransactionStorageService.loadTransactions();
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Add / Delete ─────────────────────────────────────────────────────────────

  Future<void> addTransaction(AppTransaction tx) async {
    _transactions.insert(0, tx);
    notifyListeners();
    await _persist(tx);
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
    try {
      if (FirebaseService.isAvailable) await FirebaseService.deleteTransaction(id);
    } catch (_) {}
    await TransactionStorageService.saveTransactions(_transactions);
  }

  // ── Private ───────────────────────────────────────────────────────────────────

  Future<void> _persist(AppTransaction tx) async {
    try {
      if (FirebaseService.isAvailable) await FirebaseService.saveTransaction(tx);
    } catch (_) {}
    await TransactionStorageService.saveTransactions(_transactions);
  }
}
