import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vitalife_asistant/screens/constant/Color.dart';
import 'package:vitalife_asistant/ui/responsive.dart';
import 'notification_tray.dart';

final user = FirebaseAuth.instance.currentUser;

class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('notifications')
          .where('read', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        int count = snapshot.data?.docs.length ?? 0;
        return Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_none,
                color: AppColors.primaryDark,
                size: r.s(28, min: 24, max: 32),
              ),
              onPressed: () => _showNotificationTray(context),
            ),
            if (count > 0)
              Positioned(
                right: r.s(8, min: 6, max: 10),
                top: r.s(8, min: 6, max: 10),
                child: _buildBadge(r, count),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBadge(Responsive r, int count) {
    return Container(
      padding: EdgeInsets.all(r.s(4, min: 3, max: 5)),
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      constraints: BoxConstraints(
        minWidth: r.s(16, min: 14, max: 18),
        minHeight: r.s(16, min: 14, max: 18),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: Colors.white,
          fontSize: r.s(10, min: 9, max: 11),
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _showNotificationTray(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => NotificationTray(uid: user?.uid ?? ""),
    );
  }
}
