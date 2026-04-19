// ignore_for_file: unused_field

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitalife_asistant/models/healthdata.dart';
import 'package:vitalife_asistant/screens/constant/Color.dart';
import 'package:vitalife_asistant/screens/widgets_screen/home_screen_widgets/_aiinsight_card.dart';
import 'package:vitalife_asistant/screens/widgets_screen/home_screen_widgets/_bottomnavbar.dart';
import 'package:vitalife_asistant/screens/widgets_screen/home_screen_widgets/_buildHealthCard.dart';
import 'package:vitalife_asistant/screens/widgets_screen/home_screen_widgets/_emergencydialog.dart';
import 'package:vitalife_asistant/services/firestore_service.dart';
import 'package:vitalife_asistant/services/gemini_genkit.dart';
import 'package:vitalife_asistant/services/health_service.dart';

import 'analytics_screen.dart';
import 'profile_screen.dart';

final user = FirebaseAuth.instance.currentUser;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Health data
  int? _currentHeartRate;
  int? _averageHeartRate;
  String _riskLevel = '--';

  // AI
  String _aiInsight = 'Loading health data...';

  bool _isLoading = true;
  bool _hasPermission = true;
  String? _errorMessage;

  final HealthService _healthService = HealthService();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _loadHealthData();
    _setupNotifications(); 
  }

  // ==========================================
  // 🔔 NOTIFICATION BRIDGE (SMART SYNC)
  // ==========================================
  Future<void> _setupNotifications() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true, badge: true, sound: true, criticalAlert: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _fcm.getToken();
      final currentUser = _auth.currentUser;
      if (token != null && currentUser != null) {
        await _firestoreService.updateUserFcmToken(currentUser.uid, token);
      }
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        bool isEmergency = message.data['type'] == 'emergency';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: InkWell(
              onTap: () => _showNotificationTray(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message.notification!.title ?? "Vitalife Alert", 
                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(message.notification!.body ?? "", style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            backgroundColor: isEmergency ? Colors.red.shade900 : AppColors.primaryDark,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _showNotificationTray();
    });
  }

  // =========================
  // 💓 LOAD HEALTH DATA
  // =========================
  Future<void> _loadHealthData() async {
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final healthData = await _healthService.fetchData();
      if (healthData.containsKey('error')) {
        setState(() {
          _errorMessage = healthData['error'];
          _isLoading = false;
          _hasPermission = false;
          _aiInsight = 'Sensor access required.';
        });
        return;
      }

      final data = HealthData.fromMap(healthData);
      final currentUser = _auth.currentUser;

      if (currentUser != null && data.heartRate != null) {
        await _firestoreService.saveHeartRate(
          uid: currentUser.uid,
          heartRate: data.heartRate!,
          spo2: data.spo2,
          steps: data.steps,
        );
      }

      setState(() {
        _currentHeartRate = data.heartRate;
        _callGenkitAI(data);
        _isLoading = false;
        _hasPermission = true;
      });

      await _loadAverageHeartRate();
    } catch (e) {
      setState(() { _errorMessage = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _callGenkitAI(HealthData latest) async {
    setState(() => _aiInsight = "AI is analyzing your biometrics...");
    try {
      final result = await GenkitService.analyzeHealth(heartRate: latest.heartRate ?? 0);
      final risk = (result['risk'] ?? '').toString().toLowerCase();
      final summary = (result['summary'] ?? '').toString();
      final advice = (result['advice'] ?? '').toString();

      if (user != null && risk.isNotEmpty) {
        await _firestoreService.saveAIInsight(
          uid: user!.uid, heartRate: latest.heartRate ?? 0,
          risk: risk, summary: summary, advice: advice,
        );
      }

      setState(() {
        _riskLevel = risk.isNotEmpty ? risk.toUpperCase() : 'NORMAL';
        _aiInsight = "🧠 AI Status: $risk\n\n$summary\n\n💡 Advice:\n$advice";
      });
    } catch (e) {
      setState(() => _aiInsight = "Connectivity sync active.");
    }
  }

  Future<void> _loadAverageHeartRate() async {
    try {
      final avg = await _healthService.fetchAverageHeartRate(days: 7);
      setState(() => _averageHeartRate = avg);
    } catch (_) { _averageHeartRate = _currentHeartRate; }
  }

  // ==========================================
  // 📋 NOTIFICATION TRAY (VIEW & DELETE)
  // ==========================================
  void _showNotificationTray() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _NotificationTray(uid: user?.uid ?? ""),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          const AnalyticsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _loadHealthData,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Today's Status",
                    style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold)),
                  
                  // NEW: Notification Bell with Badge
                  _buildNotificationBell(),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: HealthCard(
                    title: 'Current', value: '${_currentHeartRate ?? "--"}', unit: 'bpm',
                    icon: Icons.favorite, color: Colors.red)),
                  const SizedBox(width: 10),
                  Expanded(child: HealthCard(
                    title: 'Average', value: '${_averageHeartRate ?? "--"}', unit: 'bpm',
                    icon: Icons.trending_up, color: Colors.blue)),
                  const SizedBox(width: 10),
                  Expanded(child: HealthCard(
                    title: 'Risk', value: _riskLevel, unit: '',
                    icon: Icons.security, color: Colors.orange)),
                ],
              ),
              const SizedBox(height: 25),
              AIInsightCard(insight: _aiInsight, isLoading: _isLoading, onRefresh: _loadHealthData),
              const SizedBox(height: 25),
              GestureDetector(
                onTap: () => EmergencyDialog.show(context),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: AppColors.emergencyGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: const Center(
                    child: Text("EMERGENCY",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationBell() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users').doc(user?.uid).collection('notifications')
          .where('read', isEqualTo: false).snapshots(),
      builder: (context, snapshot) {
        int count = snapshot.data?.docs.length ?? 0;
        return Stack(
          children: [
            IconButton(
              icon: Icon(Icons.notifications_none, color: AppColors.primaryDark, size: 28),
              onPressed: _showNotificationTray,
            ),
            if (count > 0)
              Positioned(
                right: 8, top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text('$count', 
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                ),
              )
          ],
        );
      }
    );
  }
}

// ==========================================
// 🛠️ NOTIFICATION TRAY COMPONENT
// ==========================================
class _NotificationTray extends StatelessWidget {
  final String uid;
  const _NotificationTray({required this.uid});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(
            width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Notifications", style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => _clearAll(context),
                  child: const Text("Clear All", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('notifications').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                if (snapshot.data!.docs.isEmpty) return const Center(child: Text("All caught up! ✨"));

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    bool isEmergency = data['type'] == 'emergency';

                    return Dismissible(
                      key: Key(doc.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20),
                        color: Colors.red, child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => doc.reference.delete(),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isEmergency ? Colors.red.shade100 : Colors.blue.shade100,
                          child: Icon(isEmergency ? Icons.warning : Icons.info, color: isEmergency ? Colors.red : Colors.blue, size: 20),
                        ),
                        title: Text(data['title'] ?? "", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        subtitle: Text(data['message'] ?? "", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        trailing: IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () => doc.reference.delete()),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _clearAll(BuildContext context) async {
    final batch = FirebaseFirestore.instance.batch();
    final snapshots = await FirebaseFirestore.instance.collection('users').doc(uid).collection('notifications').get();
    for (var doc in snapshots.docs) { batch.delete(doc.reference); }
    await batch.commit();
  }
}