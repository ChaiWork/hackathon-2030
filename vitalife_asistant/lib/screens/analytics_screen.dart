import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitalife_asistant/screens/constant/Color.dart';
import 'package:vitalife_asistant/screens/widgets_screen/analytics_screen_widgets/_chart_card.dart';
import 'package:vitalife_asistant/screens/widgets_screen/analytics_screen_widgets/_stats_row.dart';
import 'package:vitalife_asistant/services/health_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final HealthService _healthService = HealthService();

  int? _averageHeartRate;
  int? _peakHeartRate;
  int? _minHeartRate;

  @override
  void initState() {
    super.initState();
    _init(); // ✅ CALL HERE
  }

  Future<void> _init() async {
    await _healthService.initPermissionOnce(); // 🔥 ONLY ONCE
    await _loadStats();
  }

  Future<void> _loadStats() async {
    final avg = await _healthService.fetchAverageHeartRate(days: 7);
    final max = await _healthService.fetchPeakHeartRate(days: 7);
    final min = await _healthService.fetchMinHeartRate(days: 7);

    setState(() {
      _averageHeartRate = avg;
      _peakHeartRate = max;
      _minHeartRate = min;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Analytics',
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDeep,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ChartCard(
              title: 'Weekly Heart Rate',
              subtitle: 'Last 7 days',
            ),
            const SizedBox(height: 20),

            // 🔥 REAL DATA HERE
            StatsRow(
              avgHr: _averageHeartRate?.toString() ?? '--',
              peakHr: _peakHeartRate?.toString() ?? '--',
              minHr: _minHeartRate?.toString() ?? '--',
            ),

            const SizedBox(height: 20),

            const ChartCard(title: 'Monthly Trend', subtitle: 'Last 30 days'),

            const SizedBox(height: 20),

            ChartCard(
              title: 'Daily Breakdown',
              subtitle: "Today's activity",
              icon: Icons.access_time,
              chart: _buildDailyBreakdown(),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyBreakdown() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, color: AppColors.primaryDeep, size: 40),
            const SizedBox(height: 8),
            Text(
              'Detailed hourly data will appear here',
              style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
