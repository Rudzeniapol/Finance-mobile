import 'package:flutter/material.dart';
import 'package:my_app/helpers/colors.dart';

/// Animated shimmer placeholder rendered while cards load.
class ShimmerCardLoading extends StatefulWidget {
  const ShimmerCardLoading({super.key});

  @override
  State<ShimmerCardLoading> createState() => _ShimmerCardLoadingState();
}

class _ShimmerCardLoadingState extends State<ShimmerCardLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _ctrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base    = isDark ? kDarkCard  : const Color(0xFFE8EDFF);
    final shimmer = isDark ? kDarkCard2 : const Color(0xFFCED8FF);

    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kPrimary.withValues(alpha: 0.6), kPrimary2.withValues(alpha: 0.6)],
        ),
      ),
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            shimmer.withValues(alpha: 0.0),
            shimmer.withValues(alpha: 0.5),
            shimmer.withValues(alpha: 0.0),
          ],
          stops: [
            (_ctrl.value - 0.35).clamp(0.0, 1.0),
            _ctrl.value.clamp(0.0, 1.0),
            (_ctrl.value + 0.35).clamp(0.0, 1.0),
          ],
        ).createShader(bounds),
        blendMode: BlendMode.srcATop,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Chip + delete placeholder
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _box(44, 30, radius: 6),
                  _box(36, 36, radius: 10),
                ],
              ),
              // Card number
              _box(220, 20, radius: 6),
              // Name
              _box(130, 14, radius: 4),
              // Expiry + logo row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _box(60, 10, radius: 3),
                      const SizedBox(height: 4),
                      _box(50, 14, radius: 4),
                    ],
                  ),
                  _box(46, 30, radius: 6),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _box(double w, double h, {double radius = 4}) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}
