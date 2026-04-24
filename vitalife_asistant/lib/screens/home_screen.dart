import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vitalife_asistant/models/healthdata.dart';
import 'package:vitalife_asistant/screens/analytics_screen.dart';
import 'package:vitalife_asistant/screens/constant/Color.dart';
import 'package:vitalife_asistant/screens/profile_screen.dart';
import 'package:vitalife_asistant/screens/widgets_screen/home_screen_widgets/_aiinsight_card.dart';
import 'package:vitalife_asistant/screens/widgets_screen/home_screen_widgets/_bottomnavbar.dart';
import 'package:vitalife_asistant/screens/widgets_screen/home_screen_widgets/emergency_button.dart';
import 'package:vitalife_asistant/screens/widgets_screen/home_screen_widgets/health_metrics_section.dart';
import 'package:vitalife_asistant/screens/widgets_screen/home_screen_widgets/notification_bell.dart';
import 'package:vitalife_asistant/screens/widgets_screen/home_screen_widgets/notification_tray.dart';
import 'package:vitalife_asistant/services/firestore_service.dart';
import 'package:vitalife_asistant/services/gemini_genkit.dart';
import 'package:vitalife_asistant/services/health_service.dart';
import 'package:vitalife_asistant/ui/responsive.dart';

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
  DateTime? _lastAIInsightTime;
  String? _cachedAIInsight;
  bool _isAIInsightCached = false;

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
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
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
        _showNotificationSnackbar(message, isEmergency);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _showNotificationTray();
    });
  }

  void _showNotificationSnackbar(RemoteMessage message, bool isEmergency) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: InkWell(
          onTap: () => _showNotificationTray(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.notification!.title ?? "Vitalife Alert",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                message.notification!.body ?? "",
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        backgroundColor: isEmergency
            ? Colors.red.shade900
            : AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  // =========================
  // 💓 LOAD HEALTH DATA
  // =========================
  Future<void> _loadHealthData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

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
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // ==========================================
  // 🧠 AI INSIGHT CACHING (2HR EXPIRATION)
  // ==========================================
  bool _isAIInsightExpired() {
    if (_lastAIInsightTime == null) return true;
    final elapsed = DateTime.now().difference(_lastAIInsightTime!);
    return elapsed.inMinutes > 120; // 2 hours
  }

  Future<void> _callGenkitAI(HealthData latest) async {
    // Check if cache is still valid
    if (!_isAIInsightExpired() && _cachedAIInsight != null) {
      setState(() {
        _aiInsight = _cachedAIInsight!;
        _isAIInsightCached = true;
      });
      return;
    }

    // Cache expired or doesn't exist → fetch fresh data
    setState(() {
      _aiInsight = "AI is analyzing your biometrics...";
      _isAIInsightCached = false;
    });

    try {
      final result = await GenkitService.analyzeHealth(
        heartRate: latest.heartRate ?? 0,
      );
      final risk = (result['risk'] ?? '').toString().toLowerCase();
      final summary = (result['summary'] ?? '').toString();
      final advice = (result['advice'] ?? '').toString();

      if (user != null && risk.isNotEmpty) {
        await _firestoreService.saveAIInsight(
          uid: user!.uid,
          heartRate: latest.heartRate ?? 0,
          risk: risk,
          summary: summary,
          advice: advice,
        );
      }

      final insightText =
          "🧠 AI Status: $risk\n\n$summary\n\n💡 Advice:\n$advice";
      setState(() {
        _riskLevel = risk.isNotEmpty ? risk.toUpperCase() : 'NORMAL';
        _aiInsight = insightText;
        _cachedAIInsight = insightText;
        _lastAIInsightTime = DateTime.now();
        _isAIInsightCached = false;
      });
    } catch (e) {
      setState(() => _aiInsight = "Connectivity sync active.");
    }
  }

  Future<void> _loadAverageHeartRate() async {
    try {
      final avg = await _healthService.fetchAverageHeartRate(days: 7);
      setState(() => _averageHeartRate = avg);
    } catch (_) {
      _averageHeartRate = _currentHeartRate;
    }
  }

  void _showNotificationTray() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => NotificationTray(uid: user?.uid ?? ""),
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
    final r = Responsive.of(context);
    final titleFont = r.s(24, min: 20, max: 30);
    final sectionGap = r.gapV(0.025, min: 14, max: 24);

    return RefreshIndicator(
      onRefresh: _loadHealthData,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: r.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(r, titleFont),
              SizedBox(height: sectionGap),
              HealthMetricsSection(
                currentHeartRate: _currentHeartRate,
                averageHeartRate: _averageHeartRate,
                riskLevel: _riskLevel,
              ),
              SizedBox(height: sectionGap),
              AIInsightCard(
                insight: _aiInsight,
                isLoading: _isLoading,
                onRefresh: _loadHealthData,
              ),
              SizedBox(height: sectionGap),
              const EmergencyButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Responsive r, double titleFont) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            "Today's Status",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.montserrat(
              fontSize: titleFont,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDeep,
            ),
          ),
        ),
        const NotificationBell(),
      ],
    );
  }
}
