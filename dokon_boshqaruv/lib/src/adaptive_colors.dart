import 'package:flutter/material.dart';

/// Adapts legacy component colors to the shared dark scheme while retaining
/// semantic red/green/blue cues and white text on colored action surfaces.
Color adaptiveColor(BuildContext context, Color color,
    {bool foreground = false}) {
  final theme = Theme.of(context);
  if (theme.brightness != Brightness.dark) return color;
  final hsl = HSLColor.fromColor(color);
  final luminance = color.computeLuminance();
  if (foreground) {
    if (luminance > .85 && hsl.saturation < .1) return color;
    if (hsl.saturation < .15) {
      return theme.colorScheme.onSurface.withValues(alpha: color.a);
    }
    return hsl
        .withLightness(hsl.lightness < .65 ? .72 : hsl.lightness)
        .toColor();
  }
  if (luminance > .65) {
    if (hsl.saturation < .15) return theme.colorScheme.surfaceContainerLow;
    return hsl.withLightness(.19).withSaturation(.4).toColor();
  }
  if (hsl.saturation < .1 && luminance > .12) {
    return theme.colorScheme.surfaceContainerHigh;
  }
  return color;
}
