import 'package:flutter/material.dart';
import 'package:my_app/helpers/colors.dart';

class BottomItems extends StatelessWidget {
  final IconData icon;
  final bool active;

  const BottomItems({super.key, required this.active, required this.icon});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: active
            ? kPrimary.withValues(alpha: 0.14)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        icon,
        color: active ? kPrimary : Colors.grey.withValues(alpha: 0.6),
        size: 26,
      ),
    );
  }
}
