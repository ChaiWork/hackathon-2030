import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:vitalife_asistant/screens/constant/Color.dart';
import 'package:vitalife_asistant/screens/widgets_screen/analytics_screen_widgets/_chart_card.dart';
import 'package:vitalife_asistant/screens/widgets_screen/analytics_screen_widgets/_stats_row.dart';

import 'package:vitalife_asistant/services/health_service.dart';
import 'package:vitalife_asistant/services/firestore_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final HealthService _healthService = HealthService();
  final FirestoreService _firestoreService = FirestoreService();

  final user = FirebaseAuth.instance.currentUser;

  int? _averageHeartRate;
  int? _peakHeartRate;
  int? _minHeartRate;

  List<int?> _weeklyHeartRate = [];
  List<int?> _monthlyHeartRate = [];
  List<int?> _dailyHeartRate = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _healthService.initPermissionOnce();
    await _loadStats();
    await _saveBreakdownToFirebase(); // 🔥 NEW
  }

  // =========================
  // LOAD DATA FROM DEVICE
  // =========================
  Future<void> _loadStats() async {
    final avg = await _healthService.fetchAverageHeartRate(days: 7);
    final max = await _healthService.fetchPeakHeartRate(days: 7);
    final min = await _healthService.fetchMinHeartRate(days: 7);
    final weeklyTrend =
        await _healthService.fetchWeeklyHeartRateTrend(days: 7);
    final monthlyTrend =
        await _healthService.fetchMonthlyHeartRateTrend(days: 30);
    final dailyBreakdown =
        await _healthService.fetchDailyHeartRateBreakdown();

    setState(() {
      _averageHeartRate = avg;
      _peakHeartRate = max;
      _minHeartRate = min;
      _weeklyHeartRate = weeklyTrend;
      _monthlyHeartRate = monthlyTrend;
      _dailyHeartRate = dailyBreakdown;
    });
  }

  // =========================
  // SAVE TO FIREBASE (OPTION 1)
  // =========================
  Future<void> _saveBreakdownToFirebase() async {
    if (user == null) return;

    final breakdown =
        await _healthService.fetchDailyHeartRateBreakdown();

    await _firestoreService.saveDailyBreakdown(
      uid: user!.uid,
      hourlyData: breakdown,
    );
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChartCard(
              title: 'Weekly Heart Rate',
              subtitle: 'Last 7 days',
              chart: _buildWeeklyHeartRateChart(),
            ),
            const SizedBox(height: 20),

            StatsRow(
              avgHr: _averageHeartRate?.toString() ?? '--',
              peakHr: _peakHeartRate?.toString() ?? '--',
              minHr: _minHeartRate?.toString() ?? '--',
            ),

            const SizedBox(height: 20),

            ChartCard(
              title: 'Monthly Trend',
              subtitle: 'Last 30 days',
              chart: _buildMonthlyTrendChart(),
            ),

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

  // =========================
  // DAILY CHART
  // =========================
  Widget _buildDailyBreakdown() {
    return _buildLineChart(
      data: _dailyHeartRate,
      maxX: 23,
      emptyText: 'No heart rate data for today',
      bottomLabelBuilder: (index) {
        if (index != 0 &&
            index != 6 &&
            index != 12 &&
            index != 18 &&
            index != 23) {
          return '';
        }
        return _formatHourLabel(index);
      },
    );
  }

  String _formatHourLabel(int hour) {
    if (hour == 0) return '12AM';
    if (hour < 12) return '${hour}AM';
    if (hour == 12) return '12PM';
    return '${hour - 12}PM';
  }

  Widget _buildWeeklyHeartRateChart() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    const weekDayShort = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    final dayLabels = List<String>.generate(7, (index) {
      final day = today.subtract(Duration(days: 6 - index));
      return weekDayShort[day.weekday - 1];
    });

    return _buildLineChart(
      data: _weeklyHeartRate,
      maxX: 6,
      emptyText: 'No heart rate data for this week',
      bottomLabelBuilder: (index) => dayLabels[index],
    );
  }

  Widget _buildMonthlyTrendChart() {
    return _buildLineChart(
      data: _monthlyHeartRate,
      maxX: 29,
      emptyText: 'No heart rate data for this month',
      bottomLabelBuilder: (index) {
        if (index == 0) return '-30d';
        if (index == 14) return '-15d';
        if (index == 29) return 'Today';
        return '';
      },
    );
  }

  // =========================
  // COMMON CHART BUILDER
  // =========================
  Widget _buildLineChart({
    required List<int?> data,
    required double maxX,
    required String emptyText,
    required String Function(int index) bottomLabelBuilder,
  }) {
    final spots = <FlSpot>[];

    for (var i = 0; i < data.length; i++) {
      final value = data[i];
      if (value != null) {
        spots.add(FlSpot(i.toDouble(), value.toDouble()));
      }
    }

    if (spots.isEmpty) {
      return SizedBox(
        height: 150,
        child: Center(child: Text(emptyText)),
      );
    }

    final values = spots.map((spot) => spot.y).toList();

    final minY = (values.reduce((a, b) => a < b ? a : b) - 5)
        .clamp(30, 220)
        .toDouble();

    final maxY = (values.reduce((a, b) => a > b ? a : b) + 5)
        .clamp(30, 220)
        .toDouble();

    return SizedBox(
      height: 150,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: maxX,
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 10,
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 10,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return const SizedBox.shrink();
                  }
                  final label = bottomLabelBuilder(index);
                  if (label.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      label,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              color: AppColors.primaryDeep,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primaryDeep.withOpacity(0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}