import 'package:flutter/material.dart';
import 'package:my_app/models/payment_card.dart';
import 'package:my_app/services/card_storage_service.dart';

class CardsViewModel extends ChangeNotifier {
  List<PaymentCard> _cards = [];
  bool _isLoading = true;

  List<PaymentCard> get cards => List.unmodifiable(_cards);
  bool get isLoading => _isLoading;
  int get count => _cards.length;

  CardsViewModel() {
    loadCards();
  }

  Future<void> loadCards() async {
    _isLoading = true;
    notifyListeners();
    _cards = await CardStorageService.loadCards();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCard(PaymentCard card) async {
    _cards.add(card);
    notifyListeners();
    await CardStorageService.saveCards(_cards);
  }

  Future<void> deleteCard(int index) async {
    _cards.removeAt(index);
    notifyListeners();
    await CardStorageService.saveCards(_cards);
  }
}
