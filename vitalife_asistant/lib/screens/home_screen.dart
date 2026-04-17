import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  // =========================
  // LOAD HEALTH DATA
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
          _aiInsight = 'Permission required.';
        });
        return;
      }

      // Convert to model
      final data = HealthData.fromMap(healthData);
      final user = _auth.currentUser;
      if (user != null && data.heartRate != null) {
        try {
          await _firestoreService.saveHeartRate(
            uid: user.uid,
            heartRate: data.heartRate!,
            spo2: data.spo2,
            steps: data.steps,
          );
        } catch (_) {
          // Keep UI responsive even when Firestore write fails.
        }
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
        _aiInsight = 'Failed to load data.';
      });
    }
  }

  // =========================
  // GENKIT AI CALL
  // =========================
  Future<void> _callGenkitAI(HealthData latest) async {
    setState(() {
      _aiInsight = "Analyzing your health with AI...";
    });

    try {
      final result = await GenkitService.analyzeHealth(
        heartRate: latest.heartRate ?? 0,
      );

      setState(() {
        final risk = (result['risk'] ?? 'unknown').toString();
        final summary = (result['summary'] ?? '').toString();
        final advice = (result['advice'] ?? '').toString();
        final errorCode = result['errorCode']?.toString();
        final details = result['details']?.toString();

        _riskLevel = risk.toUpperCase();

        _aiInsight =
            "🧠 AI Risk: $risk\n\n"
            "$summary\n\n"
            "💡 Advice:\n$advice"
            "${errorCode != null ? "\n\n⚠️ Error Code: $errorCode" : ""}"
            "${details != null && details.isNotEmpty ? "\nDetails: $details" : ""}";
      });
    } catch (e) {
      setState(() {
        _riskLevel = 'UNKNOWN';
        _aiInsight = _generateFallbackInsight(latest);
      });
    }
  }

  // =========================
  // AVERAGE HR
  // =========================
  Future<void> _loadAverageHeartRate() async {
    try {
      final avg = await _healthService.fetchAverageHeartRate(days: 7);
      setState(() {
        _averageHeartRate = avg;
      });
    } catch (_) {
      _averageHeartRate = _currentHeartRate;
    }
  }

  // =========================
  // FALLBACK AI
  // =========================
  String _generateFallbackInsight(HealthData data) {
    return "HR: ${data.heartRate ?? '--'} bpm\n"
        "Steps: ${data.steps}\n"
        "AI temporarily unavailable.";
  }

  // =========================
  // UI
  // =========================
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
              Text(
                "Today's Status",
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: HealthCard(
                      title: 'Current HR',
                      value: '${_currentHeartRate ?? "--"}',
                      unit: 'bpm',
                      icon: Icons.favorite,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: HealthCard(
                      title: 'Average HR',
                      value: '${_averageHeartRate ?? "--"}',
                      unit: 'bpm',
                      icon: Icons.trending_up,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: HealthCard(
                      title: 'Risk Level',
                      value: _riskLevel,
                      unit: '',
                      icon: Icons.shield,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              AIInsightCard(
                insight: _aiInsight,
                isLoading: _isLoading,
                onRefresh: _loadHealthData,
              ),

              const SizedBox(height: 25),

              GestureDetector(
                onTap: () => EmergencyDialog.show(context),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: AppColors.emergencyGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      "EMERGENCY",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
