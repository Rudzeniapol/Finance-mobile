import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/models/payment_card.dart';

class CardStorageService {
  static const _key = 'payment_cards';

  static Future<List<PaymentCard>> loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null || jsonString.isEmpty) return [];
    return PaymentCard.decodeList(jsonString);
  }

  static Future<void> saveCards(List<PaymentCard> cards) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, PaymentCard.encodeList(cards));
  }
}
