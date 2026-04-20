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
    final size = MediaQuery.sizeOf(context);

    // Keep design proportions but scale for phones/tablets/web.
    final shortest = size.shortestSide;
    final base = (shortest / 400).clamp(0.85, 1.25);
    final horizontalPadding =
        (size.width * 0.05).clamp(16.0, size.width >= 900 ? 40.0 : 28.0);
    final verticalPadding = (size.height * 0.02).clamp(12.0, 24.0);
    final sectionGap = (size.height * 0.025).clamp(14.0, 24.0);
    final bottomGap = (size.height * 0.05).clamp(24.0, 48.0);
    final titleFontSize = (24 * base).clamp(20.0, 30.0);

    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Analytics',
          style: GoogleFonts.montserrat(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDeep,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChartCard(
              title: 'Weekly Heart Rate',
              subtitle: 'Last 7 days',
              chart: _buildWeeklyHeartRateChart(),
            ),
            SizedBox(height: sectionGap),

            StatsRow(
              avgHr: _averageHeartRate?.toString() ?? '--',
              peakHr: _peakHeartRate?.toString() ?? '--',
              minHr: _minHeartRate?.toString() ?? '--',
            ),

            SizedBox(height: sectionGap),

            ChartCard(
              title: 'Monthly Trend',
              subtitle: 'Last 30 days',
              chart: _buildMonthlyTrendChart(),
            ),

            SizedBox(height: sectionGap),

            ChartCard(
              title: 'Daily Breakdown',
              subtitle: "Today's activity",
              icon: Icons.access_time,
              chart: _buildDailyBreakdown(),
            ),

            SizedBox(height: bottomGap),
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
    final size = MediaQuery.sizeOf(context);
    final shortest = size.shortestSide;
    final base = (shortest / 400).clamp(0.85, 1.25);

    final chartHeight =
        (size.height * 0.20).clamp(140.0, size.width >= 900 ? 220.0 : 190.0);
    final axisFontSize = (10 * base).clamp(9.0, 12.0);
    final leftReservedSize = (32 * base).clamp(28.0, 44.0);
    final bottomTitleTopPadding = (size.height * 0.008).clamp(4.0, 10.0);
    final barWidth = (3 * base).clamp(2.5, 4.0);

    final spots = <FlSpot>[];

    for (var i = 0; i < data.length; i++) {
      final value = data[i];
      if (value != null) {
        spots.add(FlSpot(i.toDouble(), value.toDouble()));
      }
    }

    if (spots.isEmpty) {
      return SizedBox(
        height: chartHeight,
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
      height: chartHeight,
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
                reservedSize: leftReservedSize,
                interval: 10,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: TextStyle(fontSize: axisFontSize),
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
                    padding: EdgeInsets.only(top: bottomTitleTopPadding),
                    child: Text(
                      label,
                      style: TextStyle(fontSize: axisFontSize),
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
              barWidth: barWidth,
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