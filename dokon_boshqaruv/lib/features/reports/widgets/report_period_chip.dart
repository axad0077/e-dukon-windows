import 'package:flutter/material.dart';

/// Opaque semantic colors, with foreground and background switching together.
/// No selection-color tween: it previously crossed white text over white fill.
class ReportPeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onPressed;
  final IconData? icon;
  const ReportPeriodChip(
      {super.key,
      required this.label,
      required this.selected,
      this.onPressed,
      this.icon});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = onPressed == null
        ? colors.onSurfaceVariant
        : selected
            ? colors.onPrimary
            : colors.onSurface;
    return ChoiceChip(
      selected: selected,
      onSelected: onPressed == null ? null : (_) => onPressed!(),
      color: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.surfaceContainerHighest;
        }
        return states.contains(WidgetState.selected)
            ? colors.primary
            : colors.surfaceContainerHigh;
      }),
      labelStyle: TextStyle(color: foreground, fontWeight: FontWeight.w600),
      label: Text(label),
      avatar: icon == null ? null : Icon(icon, color: foreground, size: 18),
      showCheckmark: true,
      checkmarkColor: foreground,
      side:
          BorderSide(color: selected ? colors.primary : colors.outlineVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      selectedShadowColor: Colors.transparent,
      elevation: 0,
      pressElevation: 0,
      chipAnimationStyle: ChipAnimationStyle(
          selectAnimation: AnimationStyle.noAnimation,
          enableAnimation: AnimationStyle.noAnimation),
    );
  }
}
