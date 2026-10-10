import 'package:flutter/material.dart';
import '../services/app_strings.dart';

/// Reusable calculator input: editable value + horizontal slider.
/// The controller remains the source of truth so typed and dragged values stay in sync.
class FinanceInputSlider extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String suffix;
  final double min;
  final double max;
  final int? divisions;
  final bool integer;
  final double? step;
  final ValueChanged<double>? onChanged;
  final String? helperText;

  const FinanceInputSlider({
    super.key,
    required this.label,
    required this.controller,
    required this.suffix,
    required this.min,
    required this.max,
    this.divisions,
    this.integer = false,
    this.step,
    this.onChanged,
    this.helperText,
  });

  double get _value {
    final parsed = double.tryParse(controller.text.replaceAll(',', '').trim());
    return (parsed ?? min).clamp(min, max).toDouble();
  }

  void _set(BuildContext context, double value) {
    final normalized = integer ? value.round().toDouble() : value;
    controller.text = integer ? normalized.toInt().toString() : _format(normalized);
    controller.selection = TextSelection.collapsed(offset: controller.text.length);
    onChanged?.call(normalized);
  }

  String _format(double value) {
    if (step != null && step! >= 1) return value.toStringAsFixed(0);
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(AppStrings.translate(context, label), style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              SizedBox(
                width: 116,
                height: 42,
                child: TextField(
                  controller: controller,
                  keyboardType: integer
                      ? TextInputType.number
                      : const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.right,
                  onChanged: (_) => onChanged?.call(_value),
                  decoration: InputDecoration(
                    suffixText: suffix.isEmpty ? null : suffix,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: accent,
              inactiveTrackColor: accent.withValues(alpha: .16),
              thumbColor: accent,
              overlayColor: accent.withValues(alpha: .10),
              trackHeight: 3.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: _value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: (value) => _set(context, value),
            ),
          ),
          if (helperText != null)
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(AppStrings.translate(context, helperText!), style: TextStyle(fontSize: 10.5, color: theme.colorScheme.onSurfaceVariant)),
            ),
        ],
      ),
    );
  }
}
