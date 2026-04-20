import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitalife_asistant/screens/constant/Color.dart';
import 'package:vitalife_asistant/ui/responsive.dart';


class Transparent3DButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const Transparent3DButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final buttonH = r.s(56, min: 48, max: 60);
    final outerRadius = r.s(16, min: 14, max: 18);
    final innerRadius = r.s(14.5, min: 13, max: 16);
    final borderInset = r.s(1.5, min: 1, max: 2);
    final shadowH = r.s(8, min: 6, max: 10);
    final shadowOffset = r.s(-2, min: -2, max: -2);
    final labelFont = r.s(18, min: 14, max: 18);
    final letterSpacing = r.s(1.5, min: 1.1, max: 1.5);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: buttonH,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(outerRadius),
          gradient: const LinearGradient(
            colors: [AppColors.primaryDark, AppColors.primaryDeep],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Container(
          margin: EdgeInsets.all(borderInset),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(innerRadius),
            color: Colors.white.withOpacity(0.1),
          ),
          child: Stack(
            children: [
              // 3D Shadow Effect
              Positioned(
                bottom: shadowOffset,
                left: 0,
                right: 0,
                child: Container(
                  height: shadowH,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(innerRadius),
                    ),
                    color: Colors.black.withOpacity(0.15),
                  ),
                ),
              ),
              // Button Content
              Center(
                child: Text(
                  label,
                  style: GoogleFonts.montserrat(
                    fontSize: labelFont,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: letterSpacing,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}