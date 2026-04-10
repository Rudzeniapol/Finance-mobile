import 'package:flutter/material.dart';
import 'package:my_app/models/payment_card.dart';
import 'package:my_app/services/card_storage_service.dart';
import 'package:my_app/services/firebase_service.dart';

class CardsViewModel extends ChangeNotifier {
  List<PaymentCard> _cards = [];
  bool _isLoading = true;

  List<PaymentCard> get cards => List.unmodifiable(_cards);
  bool get isLoading => _isLoading;
  int get count => _cards.length;

  CardsViewModel() {
    loadCards();
  }

  // ── Load ──────────────────────────────────────────────────────────────────────

  Future<void> loadCards() async {
    _isLoading = true;
    notifyListeners();

    if (FirebaseService.isAvailable) {
      try {
        _cards = await FirebaseService.loadCards();
        if (_cards.isEmpty) {
          // First run with Firebase: migrate any local cards to Firestore
          final local = await CardStorageService.loadCards();
          for (final card in local) {
            await FirebaseService.saveCard(card);
          }
          _cards = local;
        }
        await CardStorageService.saveCards(_cards); // keep local as cache
      } catch (_) {
        _cards = await CardStorageService.loadCards();
      }
    } else {
      _cards = await CardStorageService.loadCards();
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Add / Delete ──────────────────────────────────────────────────────────────

  Future<void> addCard(PaymentCard card) async {
    _cards.add(card);
    notifyListeners();
    await _persist(card);
  }

  Future<void> deleteCard(int index) async {
    final removed = _cards.removeAt(index);
    notifyListeners();
    try {
      if (FirebaseService.isAvailable) {
        await FirebaseService.deleteCard(removed.id);
      }
    } catch (_) {}
    await CardStorageService.saveCards(_cards);
  }

  // ── Private ───────────────────────────────────────────────────────────────────

  Future<void> _persist(PaymentCard card) async {
    try {
      if (FirebaseService.isAvailable) {
        await FirebaseService.saveCard(card);
      }
    } catch (_) {}
    await CardStorageService.saveCards(_cards);
  }
}
