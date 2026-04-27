import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/models/payment_card.dart';
import 'package:my_app/services/firebase_service.dart';

class CardStorageService {
  static String _key() {
    if (!FirebaseService.isAvailable) return 'payment_cards_anon';
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid == null ? 'payment_cards_anon' : 'payment_cards_$uid';
  }

  static Future<List<PaymentCard>> loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key());
    if (jsonString == null || jsonString.isEmpty) return [];
    return PaymentCard.decodeList(jsonString);
  }

  static Future<void> saveCards(List<PaymentCard> cards) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(), PaymentCard.encodeList(cards));
  }
}
