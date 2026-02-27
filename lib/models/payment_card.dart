import 'dart:convert';

class PaymentCard {
  final String id;
  final String cardNumber;
  final String cardholderName;
  final String expiryDate;
  final int colorValue;

  PaymentCard({
    required this.id,
    required this.cardNumber,
    required this.cardholderName,
    required this.expiryDate,
    required this.colorValue,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'cardNumber': cardNumber,
        'cardholderName': cardholderName,
        'expiryDate': expiryDate,
        'colorValue': colorValue,
      };

  factory PaymentCard.fromJson(Map<String, dynamic> json) => PaymentCard(
        id: json['id'] as String,
        cardNumber: json['cardNumber'] as String,
        cardholderName: json['cardholderName'] as String,
        expiryDate: json['expiryDate'] as String,
        colorValue: json['colorValue'] as int,
      );

  static String encodeList(List<PaymentCard> cards) =>
      jsonEncode(cards.map((c) => c.toJson()).toList());

  static List<PaymentCard> decodeList(String jsonString) {
    final List<dynamic> list = jsonDecode(jsonString);
    return list.map((e) => PaymentCard.fromJson(e as Map<String, dynamic>)).toList();
  }
}
