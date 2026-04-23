import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vitalife_asistant/screens/constant/Color.dart';
import 'package:vitalife_asistant/services/firestore_service.dart';
import 'package:vitalife_asistant/ui/responsive.dart';

class EmergencyButton extends StatelessWidget {
  const EmergencyButton({super.key});

  Future<void> _makeEmergencyCall(BuildContext context) async {
    final emergencyNumber = '999';
    final uri = Uri(scheme: 'tel', path: emergencyNumber);

    // Make the call
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }

    // Send in-app notification
    await _sendEmergencyNotification(context);
  }

  Future<void> _sendEmergencyNotification(BuildContext context) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final firestoreService = FirestoreService();

      final name = currentUser.displayName ?? "Unknown User";

      await firestoreService.saveNotification(
        uid: currentUser.uid,
        name: name, // 👈 SEND NAME HERE
        title: '🚨 EMERGENCY ALERT',
        message: '🚑 $name triggered emergency assistance request.',
        type: 'emergency',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '✓ Emergency contact activated. Help on the way!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Emergency notification error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final emergencyH = r.s(70, min: 56, max: 80);
    final emergencyRadius = r.s(20, min: 16, max: 22);

    return GestureDetector(
      onTap: () => _makeEmergencyCall(context),
      child: Container(
        height: emergencyH,
        decoration: BoxDecoration(
          gradient: AppColors.emergencyGradient,
          borderRadius: BorderRadius.circular(emergencyRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: r.s(10, min: 8, max: 14),
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            "EMERGENCY",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: r.s(20, min: 16, max: 22),
              fontWeight: FontWeight.bold,
              letterSpacing: r.s(2, min: 1.5, max: 2),
            ),
          ),
        ),
      ),
    );
  }
}
