import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitalife_asistant/screens/constant/Color.dart';
import 'package:vitalife_asistant/ui/responsive.dart';


class EditButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const EditButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final padV = r.gapV(0.01, min: 6, max: 10);
    final radius = r.s(12, min: 10, max: 14);
    final font = r.s(14, min: 12, max: 15);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: padV),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed ?? () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$label clicked - Feature coming soon'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.getPrimaryWithOpacity(0.15),
            foregroundColor: AppColors.primaryDeep,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: font,
            ),
          ),
        ),
      ),
    );
  }
}