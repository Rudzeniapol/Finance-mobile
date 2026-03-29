import 'dart:convert';

class ExchangeRate {
  final String base;
  final String date;
  final Map<String, double> rates;

  ExchangeRate({
    required this.base,
    required this.date,
    required this.rates,
  });

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    final rawRates = json['rates'] as Map<String, dynamic>;
    return ExchangeRate(
      base: json['base'] as String,
      date: json['date'] as String,
      rates: rawRates.map((k, v) => MapEntry(k, (v as num).toDouble())),
    );
  }

  Map<String, dynamic> toJson() => {
        'base': base,
        'date': date,
        'rates': rates,
      };

  static String encode(ExchangeRate rate) => jsonEncode(rate.toJson());

  static ExchangeRate decode(String jsonString) =>
      ExchangeRate.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
}
