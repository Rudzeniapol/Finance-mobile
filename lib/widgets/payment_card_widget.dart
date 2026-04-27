import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:my_app/locals/app_localizations.dart';
import 'package:my_app/models/payment_card.dart';

class PaymentCardWidget extends StatelessWidget {
  final PaymentCard card;
  final VoidCallback? onDelete;

  const PaymentCardWidget({
    super.key,
    required this.card,
    this.onDelete,
  });

  /// Darkens a colour by [amount] (0.0–1.0) in HSL space.
  Color _darken(Color color, [double amount = 0.22]) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final base = Color(card.colorValue);
    final dark = _darken(base);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [base, dark],
        ),
        boxShadow: [
          BoxShadow(
            color: base.withValues(alpha: 0.45),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle highlight overlay (top-left glow)
          Positioned(
            top: -20,
            left: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          // Card content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top row: chip + delete button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/images/chip.png', width: 44),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Share button
                        Material(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              final masked =
                                  '**** **** **** ${card.cardNumber.replaceAll(' ', '').substring(card.cardNumber.replaceAll(' ', '').length - 4)}';
                              Share.share(
                                'My card: $masked\nHolder: ${card.cardholderName}\nExpiry: ${card.expiryDate}',
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(Icons.share_outlined,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                        if (onDelete != null) ...[
                          const SizedBox(width: 8),
                          Material(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: onDelete,
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.delete_outline,
                                    color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Card number
                Text(
                  card.cardNumber,
                  style: const TextStyle(
                    fontFamily: 'PoppinsMedium',
                    fontSize: 18,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                // Cardholder name
                Text(
                  card.cardholderName.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'PoppinsRegular',
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.75),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                // Bottom row: expiry + logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.get('expiry_date_label').toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'PoppinsLight',
                            fontSize: 9,
                            color: Colors.white.withValues(alpha: 0.6),
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          card.expiryDate,
                          style: const TextStyle(
                            fontFamily: 'PoppinsMedium',
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Image.asset('assets/images/mastercard.png', width: 46),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
