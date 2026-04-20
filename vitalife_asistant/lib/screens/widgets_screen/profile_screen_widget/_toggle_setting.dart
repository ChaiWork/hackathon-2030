import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitalife_asistant/screens/constant/Color.dart';
import 'package:vitalife_asistant/ui/responsive.dart';


class ToggleSetting extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool) onChanged;

  const ToggleSetting({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final padV = r.gapV(0.01, min: 6, max: 10);
    final font = r.s(14, min: 12, max: 15);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: padV),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: font,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryDeep,
            inactiveThumbColor: Colors.grey[400],
          ),
        ],
      ),
    );
  }
}