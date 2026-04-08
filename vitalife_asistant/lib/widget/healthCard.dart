import 'package:flutter/material.dart';

/// Health Card Widget
Widget healthCard(
  String icon,
  String value,
  String title,
  Color color,
  bool isSmallScreen,
) {
  return Container(
    padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
    decoration: BoxDecoration(
      color: const Color(0xFF1B263B),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: TextStyle(fontSize: isSmallScreen ? 20 : 24)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: isSmallScreen ? 20 : (isSmallScreen ? 22 : 25),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: isSmallScreen ? 5 : 10),
        Text(
          title,
          style: TextStyle(
            color: Colors.white70,
            fontSize: isSmallScreen ? 16 : 20,
          ),
        ),
      ],
    ),
  );
}
