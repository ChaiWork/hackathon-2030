import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: selectedTab == 0 ? Colors.white : Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (selectedTab == 0)
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )
                ],
              ),
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(1),
              child: Column(
                children: [
                  Text(
                    'SIGN UP',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: selectedTab == 1 ? Colors.white : Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (selectedTab == 1)
                    Container(
                      height: 3,
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