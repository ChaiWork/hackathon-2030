import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Lightweight responsive sizing helper.
///
/// Goals:
/// - Keep existing UI structure/design intact.
/// - Provide consistent scaling for spacing, radii, and typography
///   across small phones, large phones, tablets, and web.
class Responsive {
  final Size size;

  /// Width-based breakpoints (roughly aligned with Material guidance).
  static const double phoneMax = 600;
  static const double tabletMax = 1024;

  const Responsive._(this.size);

  factory Responsive.of(BuildContext context) =>
      Responsive._(MediaQuery.sizeOf(context));

  double get w => size.width;
  double get h => size.height;
  double get shortest => size.shortestSide;

  bool get isPhone => w < phoneMax;
  bool get isTablet => w >= phoneMax && w < tabletMax;
  bool get isDesktop => w >= tabletMax;

  /// Scale factor driven by the shortest side to keep proportions stable
  /// in portrait/landscape and across platforms.
  double get scale => (shortest / 400).clamp(0.85, 1.25);

  double clamp(double value, double min, double max) =>
      math.max(min, math.min(max, value));

  /// Responsive spacing based on screen dimensions (safe for web + landscape).
  double gapH(double fraction, {double min = 0, double max = double.infinity}) =>
      clamp(w * fraction, min, max);

  double gapV(double fraction, {double min = 0, double max = double.infinity}) =>
      clamp(h * fraction, min, max);

  /// Scale a "design pixel" value with [scale] and clamp.
  double s(double designPx, {double? min, double? max}) {
    final v = designPx * scale;
    return clamp(v, min ?? 0, max ?? double.infinity);
  }

  /// Common outer padding used across screens.
  EdgeInsets get screenPadding => EdgeInsets.symmetric(
        horizontal: clamp(w * 0.05, 16, isDesktop ? 40 : 28),
        vertical: clamp(h * 0.02, 12, 24),
      );
}

