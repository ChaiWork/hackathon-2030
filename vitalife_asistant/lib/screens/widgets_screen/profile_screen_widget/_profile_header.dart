import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitalife_asistant/screens/constant/Color.dart';
import 'package:vitalife_asistant/ui/responsive.dart';


class ProfileHeader extends StatelessWidget {
  final String fullName;
  final String age;
  final String lifestyle;

  const ProfileHeader({
    super.key,
    required this.fullName,
    required this.age,
    required this.lifestyle,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final pad = r.gapH(0.05, min: 16, max: 24);
    final radius = r.s(16, min: 14, max: 18);
    final avatar = r.s(80, min: 64, max: 88);
    final avatarRadius = r.s(16, min: 14, max: 18);
    final iconSize = r.s(40, min: 32, max: 44);
    final gap = r.gapH(0.04, min: 12, max: 16);
    final nameFont = r.s(18, min: 16, max: 20);
    final subFont = r.s(12, min: 11, max: 13);
    final badgeFont = r.s(11, min: 10, max: 12);
    final badgePadH = r.s(12, min: 10, max: 14);
    final badgePadV = r.s(4, min: 3, max: 6);

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(radius),
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
      child: Row(
        children: [
          Container(
            width: avatar,
            height: avatar,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primaryDeep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(avatarRadius),
            ),
            child: Icon(Icons.person, color: Colors.white, size: iconSize),
          ),
          SizedBox(width: gap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    fontSize: nameFont,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: r.gapV(0.005, min: 3, max: 6)),
                Text(
                  '$age years • $lifestyle',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    fontSize: subFont,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: r.gapV(0.012, min: 6, max: 10)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: badgePadH,
                    vertical: badgePadV,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.getPrimaryWithOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Member since 2024',
                    style: GoogleFonts.montserrat(
                      fontSize: badgeFont,
                      color: AppColors.primaryDeep,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}