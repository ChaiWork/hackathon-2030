import 'package:flutter/material.dart';
import 'package:vitalife_asistant/ui/responsive.dart';

class LogoSection extends StatelessWidget {
  const LogoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final topGap = r.gapV(0.03, min: 16, max: 40);
    final bottomGap = r.gapV(0.015, min: 8, max: 16);
    final logoH = r.clamp(r.h * (r.isPhone ? 0.22 : 0.20), 120, 200);
    final logoW = r.clamp(logoH * 0.95, 120, 200);

    return Column(
      children: [
        SizedBox(height: topGap),
        Image.asset(
          'assets/images/vitalife_logo.png',
          height: logoH,
          width: logoW,
          fit: BoxFit.contain,
        ),
        SizedBox(height: bottomGap),
      ],
    );
  }
}
