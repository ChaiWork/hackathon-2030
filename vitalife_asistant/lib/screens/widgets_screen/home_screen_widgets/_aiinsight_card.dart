import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitalife_asistant/screens/constant/Color.dart';
import 'package:vitalife_asistant/ui/responsive.dart';


class AIInsightCard extends StatelessWidget {
  final String insight;
  final bool isLoading;
  final VoidCallback onRefresh;

  const AIInsightCard({
    super.key,
    required this.insight,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final pad = r.gapH(0.05, min: 16, max: 24);
    final radius = r.s(24, min: 18, max: 26);
    final iconPad = r.s(8, min: 6, max: 10);
    final iconRadius = r.s(12, min: 10, max: 14);
    final iconSize = r.s(20, min: 18, max: 22);
    final titleFont = r.s(16, min: 14, max: 18);
    final bodyFont = r.s(14, min: 12, max: 15);
    final headerGap = r.gapH(0.03, min: 8, max: 12);
    final contentGap = r.gapV(0.02, min: 12, max: 18);

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryLight, AppColors.primaryMedium],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.getPrimaryWithOpacity(0.2),
            blurRadius: r.s(15, min: 12, max: 18),
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(iconPad),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(iconRadius),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: AppColors.primaryDeep,
                  size: iconSize,
                ),
              ),
              SizedBox(width: headerGap),
              Text(
                'AI Health Insight',
                style: GoogleFonts.montserrat(
                  fontSize: titleFont,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDeep,
                ),
              ),
              const Spacer(),
              if (!isLoading)
                IconButton(
                  onPressed: onRefresh,
                  icon: Icon(
                    Icons.refresh,
                    color: AppColors.primaryDeep,
                    size: iconSize,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (isLoading)
                SizedBox(
                  height: iconSize,
                  width: iconSize,
                  child: CircularProgressIndicator(
                    strokeWidth: r.s(2, min: 2, max: 3),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryDeep),
                  ),
                ),
            ],
          ),
          SizedBox(height: contentGap),
          Text(
            insight,
            style: GoogleFonts.montserrat(
              fontSize: bodyFont,
              height: 1.5,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}