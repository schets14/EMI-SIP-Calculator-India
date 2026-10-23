import 'package:flutter/material.dart';
import '../utils/formatters.dart';

class AnimatedMetric extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final bool currency;

  const AnimatedMetric({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.currency = true,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 17, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 7),
                Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              currency ? money(v) : v.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        );
      },
    );
  }
}