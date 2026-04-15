import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitalife_asistant/screens/constant/Color.dart';
import 'package:vitalife_asistant/screens/widgets_screen/home_screen_widgets/_aiinsight_card.dart';
import 'package:vitalife_asistant/screens/widgets_screen/home_screen_widgets/_bottomnavbar.dart';
import 'package:vitalife_asistant/screens/widgets_screen/home_screen_widgets/_buildHealthCard.dart';
import 'package:vitalife_asistant/screens/widgets_screen/home_screen_widgets/_emergencydialog.dart';
import 'analytics_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Mock data - will be replaced with real data later
  final int _currentHeartRate = 72;
  final int _averageHeartRate = 68;
  final String _riskLevel = 'Low';
  final String _aiInsight =
      'Your heart rate is stable. Keep up with regular exercise and healthy diet.';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Home Tab
          _buildHomeTab(),
          // Analytics Tab
          const AnalyticsScreen(),
          // Profile Tab
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Today\'s Status',
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDeep,
                      ),
                    ),
                  ],
                ),
                Image.asset(
                  'assets/images/vitalife_logo.png',
                  height: 50,
                  width: 50,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Three Health Cards
            Row(
              children: [
                Expanded(
                  child: HealthCard(
                    title: 'Current HR',
                    value: '$_currentHeartRate',
                    unit: 'bpm',
                    icon: Icons.favorite,
                    color: AppColors.primaryDeep,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: HealthCard(
                    title: 'Average HR',
                    value: '$_averageHeartRate',
                    unit: 'bpm',
                    icon: Icons.trending_up,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: HealthCard(
                    title: 'Risk Level',
                    value: _riskLevel,
                    unit: '',
                    icon: Icons.shield,
                    color: _riskLevel == 'Low' ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // AI Insight Section - Using AIInsightCard
            AIInsightCard(
              insight: _aiInsight,
              isLoading: _isLoading,
              onRefresh: () async {
                setState(() {
                  _isLoading = true;
                });
                // Simulate API call
                await Future.delayed(const Duration(seconds: 2));
                setState(() {
                  _isLoading = false;
                });
                // Show refresh confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('AI insights refreshed'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Emergency Button
            SizedBox(
              width: double.infinity,
              height: 72,
              child: GestureDetector(
                onTap: () {
                  EmergencyDialog.show(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: AppColors.emergencyGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.getErrorWithOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Animated pulse effect background
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.red[300]!.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      // Button Content
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.emergency,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'EMERGENCY',
                              style: GoogleFonts.montserrat(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppColors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}