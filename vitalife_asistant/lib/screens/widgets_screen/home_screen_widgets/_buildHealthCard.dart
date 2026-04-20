import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitalife_asistant/screens/constant/Color.dart';
import 'package:vitalife_asistant/ui/responsive.dart';


class HealthCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const HealthCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final pad = r.gapH(0.04, min: 12, max: 18);
    final radius = r.s(20, min: 16, max: 22);
    final iconPad = r.s(8, min: 6, max: 10);
    final iconRadius = r.s(12, min: 10, max: 14);
    final iconSize = r.s(24, min: 20, max: 26);
    final titleFont = r.s(12, min: 11, max: 13);
    final valueFont = r.s(24, min: 18, max: 26);
    final unitFont = r.s(12, min: 11, max: 13);
    final gap1 = r.gapV(0.015, min: 8, max: 12);
    final gap2 = r.gapV(0.008, min: 3, max: 6);

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: r.s(10, min: 8, max: 14),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(iconPad),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(iconRadius),
            ),
            child: Icon(icon, color: color, size: iconSize),
          ),
          SizedBox(height: gap1),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: titleFont,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: gap2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    fontSize: valueFont,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              if (unit.isNotEmpty)
                Flexible(
                  child: Text(
                    ' $unit',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: unitFont,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
