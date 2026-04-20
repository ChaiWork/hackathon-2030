import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitalife_asistant/screens/constant/Color.dart';


class ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? chart;
  final IconData? icon;

  const ChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.chart,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final shortest = size.shortestSide;
    final base = (shortest / 400).clamp(0.85, 1.25);

    final cardPadding = (size.width * 0.04).clamp(14.0, 24.0);
    final titleFontSize = (16 * base).clamp(14.0, 18.0);
    final subtitleFontSize = (12 * base).clamp(11.0, 14.0);
    final iconPad = (8 * base).clamp(6.0, 10.0);
    final iconSize = (20 * base).clamp(18.0, 24.0);
    final headerGap = (size.height * 0.006).clamp(3.0, 6.0);
    final contentGap = (size.height * 0.02).clamp(16.0, 28.0);

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryMedium.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.getPrimaryWithOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDeep,
                      ),
                    ),
                    SizedBox(height: headerGap),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        fontSize: subtitleFontSize,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: (size.width * 0.02).clamp(8.0, 16.0)),
              Container(
                padding: EdgeInsets.all(iconPad),
                decoration: BoxDecoration(
                  color: AppColors.getPrimaryWithOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon ?? Icons.show_chart,
                  color: AppColors.primaryDeep,
                  size: iconSize,
                ),
              ),
            ],
          ),
          SizedBox(height: contentGap),
          // Chart Content
          chart ??
              Container(
                height: (size.height * 0.20).clamp(140.0, size.width >= 900 ? 220.0 : 190.0),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Chart will be displayed here\n(Integration with charts library pending)',
                    style: GoogleFonts.montserrat(
                      fontSize: subtitleFontSize,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}