import 'package:flutter/material.dart';
import 'package:vitalife_asistant/logic/health_utils.dart';
import 'package:vitalife_asistant/widget/add_measurement_dialog.dart';
import 'package:vitalife_asistant/widget/ai_insight_card.dart';
import 'package:vitalife_asistant/widget/blood_pressure_graph.dart';
import 'package:vitalife_asistant/widget/bottomnavbar.dart';
import 'package:vitalife_asistant/widget/healthCard.dart';
import 'package:vitalife_asistant/widget/recent_readings_list.dart';
import 'package:vitalife_asistant/widget/statistics_dialog.dart';
import '../models/health_models.dart';
import '../services/gemini_service.dart';

class HealthDashboard extends StatefulWidget {
  const HealthDashboard({super.key});

  @override
  State<HealthDashboard> createState() => _HealthDashboardState();
}

class _HealthDashboardState extends State<HealthDashboard> {
  // Data
  Map<String, double> systolicReadings = {
    "Mon": 120,
    "Tue": 180,
    "Wed": 200,
    "Thu": 10,
    "Fri": 90,
    "Sat": 50,
    "Sun": 130,
  };
  final List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  List<HealthReading> allReadings = [];

  // Current metrics
  HealthMetrics currentMetrics = HealthMetrics(
    bloodPressure: "142/90",
    heartRate: "78 bpm",
    bloodGlucose: "6.8 mmol",
    spo2: "98 %",
  );

  // UI State
  int _selectedNavIndex = 0;
  String _aiInsight = "Loading AI insights...";
  bool _isLoadingInsight = false;
  final GeminiService _geminiService = GeminiService();

  @override
  void initState() {
    super.initState();
    _addSampleReading();
    _initializeGemini();
  }

  void _addSampleReading() {
    allReadings.add(
      HealthReading(
        date: HealthUtils.getCurrentDate(),
        day: HealthUtils.getCurrentDay(),
        systolic: 142,
        diastolic: 90,
        heartRate: 78,
        glucose: 6.8,
        spo2: 98,
      ),
    );
  }

  Future<void> _initializeGemini() async {
    await _geminiService.initialize();
    await _refreshAIInsights();
  }

  Future<void> _refreshAIInsights() async {
    setState(() => _isLoadingInsight = true);
    try {
      final insight = await _geminiService.analyzeBloodPressureTrend(
        systolicReadings,
        allReadings.map((r) => r.toMap()).toList(),
      );
      setState(() => _aiInsight = insight);
    } catch (e) {
      setState(() => _aiInsight = "AI insights temporarily unavailable.");
    } finally {
      setState(() => _isLoadingInsight = false);
    }
  }

  void _showAddMeasurementDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AddMeasurementDialog(
          onSave: (Map<String, dynamic> data) async {
            setState(() {
              currentMetrics = HealthMetrics(
                bloodPressure: "${data['systolic']}/${data['diastolic']}",
                heartRate: "${data['heartRate']} bpm",
                bloodGlucose: "${data['glucose']} mmol",
                spo2: "${data['spo2']} %",
              );
              systolicReadings[HealthUtils.getCurrentDay()] = data['systolic']
                  .toDouble();

              allReadings.add(
                HealthReading(
                  date: HealthUtils.getCurrentDate(),
                  day: HealthUtils.getCurrentDay(),
                  systolic: data['systolic'],
                  diastolic: data['diastolic'],
                  heartRate: data['heartRate'],
                  glucose: data['glucose'],
                  spo2: data['spo2'],
                ),
              );
            });

            await _refreshAIInsights();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Measurements added successfully!"),
                backgroundColor: Colors.green,
              ),
            );
          },
        );
      },
    );
  }

  void _showAllReadings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("All Blood Pressure Readings"),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: allReadings.length,
              itemBuilder: (context, index) {
                final reading = allReadings.reversed.toList()[index];
                return ListTile(
                  title: Text(
                    "${reading.date} (${reading.day}): ${reading.systolic}/${reading.diastolic}",
                  ),
                  subtitle: Text(
                    "HR: ${reading.heartRate} bpm | Glucose: ${reading.glucose} mmol | SpO2: ${reading.spo2}%",
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _showAIInsightsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("AI Health Assistant"),
          content: FutureBuilder<String>(
            future: _geminiService.getPersonalizedAdvice(
              currentMetrics.bloodPressure,
              currentMetrics.heartRate,
              currentMetrics.bloodGlucose,
              currentMetrics.spo2,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.blue, size: 40),
                  const SizedBox(height: 16),
                  Text(
                    snapshot.data ?? "Keep up with your health monitoring!",
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: screenHeight * 0.05,
          right: screenWidth * 0.02,
        ),
        child: FloatingActionButton(
          onPressed: _showAddMeasurementDialog,
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(
                    isSmallScreen ? 16 : (isTablet ? 24 : 32),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(isSmallScreen),
                      const SizedBox(height: 25),
                      AIInsightCard(
                        insight: _aiInsight,
                        isLoading: _isLoadingInsight,
                        onRefresh: _refreshAIInsights,
                      ),
                      const SizedBox(height: 25),
                      if (HealthUtils.isBloodPressureHigh(
                        currentMetrics.bloodPressure,
                      ))
                        _buildAlertBox(isSmallScreen),
                      const SizedBox(height: 25),
                      _buildHealthCardsGrid(isSmallScreen, isTablet),
                      const SizedBox(height: 20),
                      BloodPressureGraph(
                        systolicReadings: systolicReadings,
                        days: days,
                        onViewAll: _showAllReadings,
                      ),
                      RecentReadingsList(readings: allReadings),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: isSmallScreen ? 10 : 16,
                left: isSmallScreen ? 10 : 16,
                right: isSmallScreen ? 10 : 16,
              ),
              child: BottomNavBar(
                currentIndex: _selectedNavIndex,
                onTap: (index) {
                  setState(() => _selectedNavIndex = index);
                  switch (index) {
                    case 1:
                      StatisticsDialog.show(context, allReadings);
                      break;
                    case 3:
                      _showAIInsightsDialog();
                      break;
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Good morning",
              style: TextStyle(
                color: Colors.white70,
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Encik Rashid",
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen
                    ? 20
                    : (MediaQuery.of(context).size.width >= 600 ? 28 : 32),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: isSmallScreen ? 20 : 28,
          backgroundColor: Colors.blue,
          child: Text(
            "ER",
            style: TextStyle(fontSize: isSmallScreen ? 14 : 18),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertBox(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.6),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.red, size: isSmallScreen ? 20 : 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "⚠️ Blood pressure elevated",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Consult your doctor for personalized advice",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isSmallScreen ? 10 : 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthCardsGrid(bool isSmallScreen, bool isTablet) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isSmallScreen ? 2 : (isTablet ? 3 : 4),
      mainAxisSpacing: isSmallScreen ? 12 : 16,
      crossAxisSpacing: isSmallScreen ? 12 : 16,
      childAspectRatio: isSmallScreen ? 1.2 : (isTablet ? 1.3 : 1.4),
      children: [
        healthCard(
          "❤️",
          currentMetrics.bloodPressure,
          "Blood Pressure",
          HealthUtils.getBloodPressureColor(currentMetrics.bloodPressure),
          isSmallScreen,
        ),
        healthCard(
          "💓",
          currentMetrics.heartRate,
          "Heart Rate",
          HealthUtils.getHeartRateColor(currentMetrics.heartRate),
          isSmallScreen,
        ),
        healthCard(
          "🩸",
          currentMetrics.bloodGlucose,
          "Blood Glucose",
          HealthUtils.getGlucoseColor(currentMetrics.bloodGlucose),
          isSmallScreen,
        ),
        healthCard(
          "🫁",
          currentMetrics.spo2,
          "SpO₂",
          HealthUtils.getSpO2Color(currentMetrics.spo2),
          isSmallScreen,
        ),
      ],
    );
  }
}
