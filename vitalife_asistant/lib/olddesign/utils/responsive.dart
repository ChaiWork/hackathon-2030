// ============================================
// 1. RESPONSIVE HELPER CLASS
// ============================================
import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Responsive padding
  static EdgeInsets padding(BuildContext context) {
    final width = screenWidth(context);
    if (width < 600) return const EdgeInsets.all(16);
    if (width < 1200) return const EdgeInsets.all(32);
    return const EdgeInsets.all(64);
  }

  // Responsive horizontal padding
  static EdgeInsets horizontalPadding(BuildContext context) {
    final width = screenWidth(context);
    if (width < 600) return const EdgeInsets.symmetric(horizontal: 16);
    if (width < 1200) return const EdgeInsets.symmetric(horizontal: 32);
    return const EdgeInsets.symmetric(horizontal: 80);
  }

  // Responsive font size
  static double fontSize(BuildContext context, {double base = 14}) {
    if (isMobile(context)) return base;
    if (isTablet(context)) return base * 1.2;
    return base * 1.4;
  }

  // Responsive title size
  static double titleSize(BuildContext context) {
    if (isMobile(context)) return 18;
    if (isTablet(context)) return 22;
    return 26;
  }

  // Responsive button height
  static double buttonHeight(BuildContext context) {
    if (isMobile(context)) return 48;
    return 56;
  }
}
