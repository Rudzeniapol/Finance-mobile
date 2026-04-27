import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:my_app/helpers/colors.dart';

class TransactionWidget extends StatelessWidget {
  final String title;
  final String image;
  final String date;
  final String ammount;

  const TransactionWidget({
    super.key,
    required this.ammount,
    required this.date,
    required this.image,
    required this.title,
  });

  void _share() {
    Share.share('$title  $ammount  ($date)');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPositive = ammount.startsWith('+');

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              image,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          date,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ammount,
              style: TextStyle(
                fontFamily: 'PoppinsMedium',
                fontSize: 14,
                color: isPositive ? kSuccess : kDanger,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _share,
              child: Icon(
                Icons.share_outlined,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
