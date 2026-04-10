import 'dart:convert';

enum TransactionCategory { food, transfer, shopping, utilities, other }

class AppTransaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionCategory category;
  final String iconPath;

  AppTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.iconPath,
  });

  /// Positive amounts are shown as "+$X", negative as "-$X"
  String get formattedAmount => amount >= 0
      ? '+\$${amount.toStringAsFixed(2)}'
      : '-\$${amount.abs().toStringAsFixed(2)}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
        'category': category.name,
        'iconPath': iconPath,
      };

  factory AppTransaction.fromJson(Map<String, dynamic> json) => AppTransaction(
        id: json['id'] as String,
        title: json['title'] as String,
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
        category: TransactionCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => TransactionCategory.other,
        ),
        iconPath: json['iconPath'] as String,
      );

  static String encodeList(List<AppTransaction> list) =>
      jsonEncode(list.map((t) => t.toJson()).toList());

  static List<AppTransaction> decodeList(String jsonString) {
    final list = jsonDecode(jsonString) as List;
    return list
        .map((e) => AppTransaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Default seed data matching the existing hardcoded transactions
  static List<AppTransaction> get defaults => [
        AppTransaction(
          id: 'tx_default_1',
          title: 'KFC',
          amount: 2010,
          date: DateTime(2020, 6, 14),
          category: TransactionCategory.food,
          iconPath: 'assets/images/burger.png',
        ),
        AppTransaction(
          id: 'tx_default_2',
          title: 'Paypal',
          amount: 12010,
          date: DateTime(2020, 6, 28),
          category: TransactionCategory.transfer,
          iconPath: 'assets/images/paypal.png',
        ),
        AppTransaction(
          id: 'tx_default_3',
          title: 'Car Repair',
          amount: 232010,
          date: DateTime(2020, 8, 28),
          category: TransactionCategory.other,
          iconPath: 'assets/images/maintenance.png',
        ),
      ];
}
