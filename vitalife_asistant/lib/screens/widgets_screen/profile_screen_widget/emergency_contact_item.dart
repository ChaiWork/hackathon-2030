import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitalife_asistant/screens/constant/Color.dart';
import 'package:vitalife_asistant/ui/responsive.dart';


class EmergencyContactItem extends StatelessWidget {
  final String name;
  final String phone;
  final VoidCallback onDelete;

  const EmergencyContactItem({
    super.key,
    required this.name,
    required this.phone,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final padV = r.gapV(0.01, min: 6, max: 10);
    final pad = r.gapH(0.03, min: 10, max: 14);
    final radius = r.s(12, min: 10, max: 14);
    final phoneFont = r.s(12, min: 11, max: 13);
    final deleteSize = r.s(22, min: 20, max: 24);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: padV),
      child: Container(
        padding: EdgeInsets.all(pad),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: AppColors.primaryMedium.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    phone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: phoneFont,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red, size: deleteSize),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}