import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitalife_asistant/ui/responsive.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final font = r.s(14, min: 12, max: 15);
    final padV = r.gapV(0.01, min: 6, max: 10);
    final labelColor = Colors.grey[600];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: padV),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.montserrat(
                fontSize: font,
                color: labelColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: r.gapH(0.04, min: 12, max: 20)),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: GoogleFonts.montserrat(
                fontSize: font,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
