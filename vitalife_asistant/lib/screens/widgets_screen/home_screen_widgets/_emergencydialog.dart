import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitalife_asistant/screens/constant/Color.dart';
import 'package:vitalife_asistant/ui/responsive.dart';


class EmergencyDialog {
  static Future<void> show(BuildContext context) {
    final r = Responsive.of(context);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(r.s(20, min: 16, max: 22)),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(r.s(8, min: 6, max: 10)),
              decoration: BoxDecoration(
                color: AppColors.getErrorWithOpacity(0.2),
                borderRadius: BorderRadius.circular(r.s(10, min: 8, max: 12)),
              ),
              child: Icon(
                Icons.emergency,
                color: AppColors.error,
                size: r.s(24, min: 20, max: 28),
              ),
            ),
            SizedBox(width: r.gapH(0.03, min: 8, max: 12)),
            Text(
              'Emergency Alert',
              style: GoogleFonts.montserrat(
                fontSize: r.s(18, min: 16, max: 20),
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
          ],
        ),
        content: Text(
          'Notifying emergency contacts...',
          style: GoogleFonts.montserrat(
            fontSize: r.s(14, min: 12, max: 15),
            color: Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Emergency services notified'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(r.s(10, min: 8, max: 12)),
              ),
            ),
            child: Text(
              'Confirm',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}