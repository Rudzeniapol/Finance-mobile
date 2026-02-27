import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Color(card.colorValue),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'assets/images/chip.png',
                  width: 50,
                ),
                if (onDelete != null)
                  Material(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: onDelete,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              card.cardNumber,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              card.cardholderName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.get('expiry_date_label'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      card.expiryDate,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                Image.asset(
                  'assets/images/mastercard.png',
                  width: 50,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
