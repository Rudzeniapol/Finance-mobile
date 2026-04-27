import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/models/payment_card.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/services/card_storage_service.dart';
import 'package:my_app/services/firebase_service.dart';

class CardsViewModel extends ChangeNotifier {
  List<PaymentCard> _cards = [];
  bool _isLoading = true;
  StreamSubscription? _streamSub;
  StreamSubscription<User?>? _authSub;
  String? _currentUid;

  List<PaymentCard> get cards => List.unmodifiable(_cards);
  bool get isLoading => _isLoading;
  int get count => _cards.length;

  CardsViewModel() {
    _currentUid = FirebaseService.isAvailable
        ? FirebaseAuth.instance.currentUser?.uid
        : null;
    loadCards();
    _authSub = AuthService.authStateChanges.listen((user) {
      final newUid = user?.uid;
      if (newUid == _currentUid) return;
      _currentUid = newUid;
      _streamSub?.cancel();
      _streamSub = null;
      _cards = [];
      loadCards();
    });
  }

  // ── Load ──────────────────────────────────────────────────────────────────────

  Future<void> loadCards() async {
    _isLoading = true;
    notifyListeners();

    if (FirebaseService.isAvailable && FirebaseAuth.instance.currentUser != null) {
      try {
        _cards = await FirebaseService.loadCards();
        if (_cards.isEmpty) {
          // First sign-in for this user: promote any local cache (now keyed
          // per-uid, so it only contains *this* user's cards) to Firestore.
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
      _listenToStream();
    } else {
      _cards = await CardStorageService.loadCards();
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Real-time stream ──────────────────────────────────────────────────────────

  void _listenToStream() {
    _streamSub?.cancel();
    _streamSub = FirebaseService.cardsStream().listen(
      (cards) {
        _cards = cards;
        CardStorageService.saveCards(_cards);
        notifyListeners();
      },
      onError: (_) {},
    );
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

  @override
  void dispose() {
    _streamSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }
}
