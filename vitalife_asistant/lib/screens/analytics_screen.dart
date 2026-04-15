import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitalife_asistant/screens/constant/Color.dart';
import 'package:vitalife_asistant/screens/widgets_screen/analytics_screen_widgets/_chart_card.dart';
import 'package:vitalife_asistant/screens/widgets_screen/analytics_screen_widgets/_stats_row.dart';


class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

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
            // Weekly Heart Rate Chart
            const ChartCard(
              title: 'Weekly Heart Rate',
              subtitle: 'Last 7 days',
            ),
            const SizedBox(height: 20),

            // Statistics Cards
            const StatsRow(
              avgHr: '68',
              peakHr: '92',
              minHr: '55',
            ),
            const SizedBox(height: 20),

            // Monthly Trend
            const ChartCard(
              title: 'Monthly Trend',
              subtitle: 'Last 30 days',
            ),
            const SizedBox(height: 20),

            // Daily Breakdown
            ChartCard(
              title: 'Daily Breakdown',
              subtitle: 'Today\'s activity',
              icon: Icons.access_time,
              chart: _buildDailyBreakdown(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Example of custom chart for daily breakdown
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
            Icon(
              Icons.favorite,
              color: AppColors.primaryDeep,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              'Detailed hourly data will appear here',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}