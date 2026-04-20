import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitalife_asistant/screens/constant/Color.dart';
import 'package:vitalife_asistant/ui/responsive.dart';


class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final bool isPassword;
  final bool obscurePassword;
  final VoidCallback? onPasswordToggle;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.obscurePassword = false,
    this.onPasswordToggle,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final fieldH = r.s(56, min: 48, max: 60);
    final outerRadius = r.s(16, min: 14, max: 18);
    final innerRadius = r.s(14.5, min: 13, max: 16);
    final borderInset = r.s(1.5, min: 1, max: 2);
    final fontSize = r.s(15, min: 13, max: 16);
    final padH = r.s(20, min: 16, max: 22);
    final padV = r.s(16, min: 12, max: 18);
    final iconLeft = r.s(16, min: 12, max: 18);
    final iconRight = r.s(12, min: 10, max: 14);
    final iconSize = r.s(22, min: 20, max: 24);

    return Container(
      height: fieldH,
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
          color: Colors.white.withOpacity(0.12),
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword ? obscurePassword : false,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: fontSize,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
            hintText: hint,
            hintStyle: GoogleFonts.montserrat(
              color: Colors.white.withOpacity(0.6),
              fontSize: fontSize,
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: iconLeft, right: iconRight),
              child: Icon(
                icon,
                color: Colors.white.withOpacity(0.7),
                size: iconSize,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0),
            suffixIcon: isPassword
                ? GestureDetector(
                    onTap: onPasswordToggle,
                    child: Padding(
                      padding: EdgeInsets.only(right: iconLeft),
                      child: Icon(
                        obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.white.withOpacity(0.7),
                        size: iconSize,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}