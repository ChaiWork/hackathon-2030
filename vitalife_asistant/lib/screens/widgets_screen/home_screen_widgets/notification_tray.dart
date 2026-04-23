import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vitalife_asistant/ui/responsive.dart';

class NotificationTray extends StatelessWidget {
  final String uid;
  const NotificationTray({required this.uid});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final trayH = r.clamp(r.h * 0.7, 360, r.h);
    final radius = r.s(30, min: 22, max: 34);
    final handleW = r.s(40, min: 34, max: 46);
    final handleH = r.s(4, min: 3, max: 5);
    final headerPadH = r.gapH(0.06, min: 16, max: 24);
    final headerPadV = r.gapV(0.01, min: 6, max: 10);
    final headerFont = r.s(20, min: 16, max: 22);

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Container(
          height: trayH,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
          ),
          child: Column(
            children: [
              _buildHandle(r, handleW, handleH),
              _buildHeader(context, r, headerPadH, headerPadV, headerFont),
              const Divider(),
              _buildNotificationsList(context, uid, r),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle(Responsive r, double handleW, double handleH) {
    return Container(
      width: handleW,
      height: handleH,
      margin: EdgeInsets.symmetric(vertical: r.s(12, min: 10, max: 14)),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(r.s(2, min: 2, max: 3)),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Responsive r,
    double padH,
    double padV,
    double fontSize,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              "Notifications",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.montserrat(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _clearAll(context),
            child: Text(
              "Clear All",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: r.s(14, min: 12, max: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(
    BuildContext context,
    String uid,
    Responsive r,
  ) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("All caught up! ✨"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            padding: EdgeInsets.symmetric(
              horizontal: r.gapH(0.04, min: 12, max: 20),
            ),
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              return _buildNotificationTile(doc, data, r);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationTile(
    DocumentSnapshot doc,
    Map<String, dynamic> data,
    Responsive r,
  ) {
    bool isEmergency = data['type'] == 'emergency';
    String? link = data['link'];

    return Dismissible(
      key: Key(doc.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: r.s(20, min: 16, max: 24)),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => doc.reference.delete(),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isEmergency
              ? Colors.red.shade100
              : Colors.blue.shade100,
          child: Icon(
            isEmergency ? Icons.warning : Icons.info,
            color: isEmergency ? Colors.red : Colors.blue,
            size: r.s(20, min: 18, max: 22),
          ),
        ),
        title: Text(
          data['title'] ?? "",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: r.s(14, min: 12, max: 14),
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              data['message'] ?? "",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: r.s(12, min: 11, max: 12),
                color: Colors.grey,
              ),
            ),
            if (link != null)
              GestureDetector(
                onTap: () => _launchLink(link),
                child: Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    link,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: r.s(11, min: 10, max: 12),
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.close, size: r.s(16, min: 14, max: 18)),
          onPressed: () => doc.reference.delete(),
        ),
      ),
    );
  }

  Future<void> _launchLink(String link) async {
    try {
      final uri = Uri.parse(link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Could not launch link: $e');
    }
  }

  Future<void> _clearAll(BuildContext context) async {
    final batch = FirebaseFirestore.instance.batch();
    final snapshots = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .get();
    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
