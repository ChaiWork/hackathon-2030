import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitalife_asistant/ui/responsive.dart';

class AuthTabBar extends StatelessWidget {
  final int selectedTab;
  final Function(int) onTabChanged;

  const AuthTabBar({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final padH = r.gapH(0.06, min: 16, max: 28);
    final tabGap = r.gapH(0.06, min: 20, max: 32);
    final labelFont = r.s(18, min: 14, max: 18);
    final underlineH = r.s(3, min: 2, max: 3);
    final underlineGap = r.gapV(0.01, min: 6, max: 10);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padH),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(0),
              child: Column(
                children: [
                  Text(
                    'LOGIN',
                    style: GoogleFonts.montserrat(
                      fontSize: labelFont,
                      fontWeight: FontWeight.w600,
                      color: selectedTab == 0 ? Colors.white : Colors.white60,
                    ),
                  ),
                  SizedBox(height: underlineGap),
                  if (selectedTab == 0)
                    Container(
                      height: underlineH,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )
                ],
              ),
            ),
          ),
          SizedBox(width: tabGap),
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(1),
              child: Column(
                children: [
                  Text(
                    'SIGN UP',
                    style: GoogleFonts.montserrat(
                      fontSize: labelFont,
                      fontWeight: FontWeight.w600,
                      color: selectedTab == 1 ? Colors.white : Colors.white60,
                    ),
                  ),
                  SizedBox(height: underlineGap),
                  if (selectedTab == 1)
                    Container(
                      height: underlineH,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}