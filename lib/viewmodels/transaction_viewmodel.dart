import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/models/transaction.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/services/firebase_service.dart';
import 'package:my_app/services/transaction_storage_service.dart';

class TransactionViewModel extends ChangeNotifier {
  List<AppTransaction> _transactions = [];
  bool _isLoading = true;
  StreamSubscription? _streamSub;
  StreamSubscription<User?>? _authSub;
  String? _currentUid;

  List<AppTransaction> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;

  TransactionViewModel() {
    _currentUid = FirebaseService.isAvailable
        ? FirebaseAuth.instance.currentUser?.uid
        : null;
    loadTransactions();
    _authSub = AuthService.authStateChanges.listen((user) {
      final newUid = user?.uid;
      if (newUid == _currentUid) return;
      _currentUid = newUid;
      _streamSub?.cancel();
      _streamSub = null;
      _transactions = [];
      loadTransactions();
    });
  }

  // ── Load ─────────────────────────────────────────────────────────────────────

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    if (FirebaseService.isAvailable && FirebaseAuth.instance.currentUser != null) {
      try {
        _transactions = await FirebaseService.loadTransactions();
        if (_transactions.isEmpty) {
          // First sign-in for this user: seed defaults so the UI isn't empty.
          for (final tx in AppTransaction.defaults) {
            await FirebaseService.saveTransaction(tx);
          }
          _transactions = AppTransaction.defaults;
        }
        await TransactionStorageService.saveTransactions(_transactions);
      } catch (_) {
        _transactions = await TransactionStorageService.loadTransactions();
      }
      _listenToStream();
    } else {
      _transactions = await TransactionStorageService.loadTransactions();
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Real-time stream ──────────────────────────────────────────────────────────

  void _listenToStream() {
    _streamSub?.cancel();
    _streamSub = FirebaseService.transactionsStream().listen(
      (txList) {
        _transactions = txList;
        TransactionStorageService.saveTransactions(_transactions);
        notifyListeners();
      },
      onError: (_) {},
    );
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

  @override
  void dispose() {
    _streamSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }
}
