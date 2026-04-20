import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitalife_asistant/screens/constant/Color.dart';
import 'package:vitalife_asistant/ui/responsive.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  final VoidCallback? onEdit;
  final bool showEditButton;

  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.onEdit,
    this.showEditButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final radius = r.s(16, min: 14, max: 18);
    final headerPad = r.gapH(0.04, min: 12, max: 18);
    final iconPad = r.s(8, min: 6, max: 10);
    final iconRadius = r.s(10, min: 8, max: 12);
    final iconSize = r.s(20, min: 18, max: 22);
    final titleFont = r.s(16, min: 14, max: 18);
    final contentPad = r.gapH(0.04, min: 12, max: 18);
    final contentGap = r.gapV(0.02, min: 12, max: 18);

    return Container(
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
      child: Column(
        children: [
          // HEADER
          Container(
            padding: EdgeInsets.all(headerPad),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.primaryMedium.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(iconPad),
                  decoration: BoxDecoration(
                    color: AppColors.getPrimaryWithOpacity(0.15),
                    borderRadius: BorderRadius.circular(iconRadius),
                  ),
                  child: Icon(icon, color: AppColors.primaryDeep, size: iconSize),
                ),
                SizedBox(width: r.gapH(0.03, min: 8, max: 12)),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: titleFont,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDeep,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // CONTENT
          Padding(
            padding: EdgeInsets.all(contentPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...children,

                SizedBox(height: contentGap),

                // EDIT BUTTON BELOW WEIGHT
                if (showEditButton)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit),
                      label: const Text("Edit"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDeep,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: r.s(12, min: 10, max: 14),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(r.s(12, min: 10, max: 14)),
                        ),
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
