import 'package:flutter/material.dart';

// ============================================
// 1. SYMPTOM RESULT CONTAINER (Your requested widget)
// ============================================
class SymptomResultContainer extends StatelessWidget {
  final String riskLevel;
  final String reason;
  final String recommendation;
  final VoidCallback? onEmergencyPressed;

  const SymptomResultContainer({
    Key? key,
    required this.riskLevel,
    required this.reason,
    required this.recommendation,
    this.onEmergencyPressed,
  }) : super(key: key);

  Color get _riskColor {
    switch (riskLevel.toUpperCase()) {
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData get _riskIcon {
    switch (riskLevel.toUpperCase()) {
      case 'HIGH':
        return Icons.warning_amber;
      case 'MEDIUM':
        return Icons.local_hospital;
      case 'LOW':
        return Icons.health_and_safety;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _riskColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _riskColor.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: _riskColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Risk Level Row with Icon
          Row(
            children: [
              Icon(_riskIcon, color: _riskColor, size: 30),
              SizedBox(width: 10),
              Text(
                "Risk Level: $riskLevel",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _riskColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // Reason Section
          Text(
            "Reason:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(reason, style: TextStyle(fontSize: 14)),

          const SizedBox(height: 15),

          // Recommendation Section
          Text(
            "Recommendation:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(recommendation, style: TextStyle(fontSize: 14)),

          // Emergency Button (only for HIGH risk)
          if (riskLevel.toUpperCase() == 'HIGH') ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onEmergencyPressed ?? () {},
                icon: Icon(Icons.emergency),
                label: Text(
                  'EMERGENCY - SEEK HELP NOW',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
