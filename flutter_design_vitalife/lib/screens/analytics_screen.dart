import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Color Palette
const Color _color1 = Color(0xFFE7ECFF);
const Color _color2 = Color(0xFFD8E1FF);
const Color _color3 = Color(0xFFBBD0FF);
const Color _color4 = Color(0xFFA8BCFB);
const Color _color5 = Color(0xFF7EA0EA);

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _color1,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Analytics',
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _color5,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekly Heart Rate Chart Placeholder
            _buildChartCard(
              title: 'Weekly Heart Rate',
              subtitle: 'Last 7 days',
            ),
            const SizedBox(height: 20),

            // Statistics Cards
            _buildStatsRow(),
            const SizedBox(height: 20),

            // Monthly Trend
            _buildChartCard(
              title: 'Monthly Trend',
              subtitle: 'Last 30 days',
            ),
            const SizedBox(height: 20),

            // Daily Breakdown
            _buildChartCard(
              title: 'Daily Breakdown',
              subtitle: 'Today\'s activity',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _color3.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _color5.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _color5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _color5.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.show_chart,
                  color: _color5,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Chart Placeholder
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: _color1,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Chart will be displayed here\n(Integration with charts library pending)',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'Avg HR',
            value: '68',
            unit: 'bpm',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: 'Peak HR',
            value: '92',
            unit: 'bpm',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: 'Min HR',
            value: '55',
            unit: 'bpm',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String unit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _color3.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _color5,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
