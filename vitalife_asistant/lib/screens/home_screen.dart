import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitalife_asistant/screens/constant/Color.dart';
import 'package:vitalife_asistant/screens/widgets_screen/home_screen_widgets/_aiinsight_card.dart';
import 'package:vitalife_asistant/screens/widgets_screen/home_screen_widgets/_bottomnavbar.dart';
import 'package:vitalife_asistant/screens/widgets_screen/home_screen_widgets/_buildHealthCard.dart';
import 'package:vitalife_asistant/screens/widgets_screen/home_screen_widgets/_emergencydialog.dart';
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
  String _aiInsight = 'Loading health data...';
  bool _isLoading = true;
  bool _hasPermission = true;
  String? _errorMessage;
  
  // For average calculation (store last 7 days heart rates)
  List<int> _heartRateHistory = [];
  
  final HealthService _healthService = HealthService();

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

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
          _aiInsight = 'Please grant health permissions to see your data.';
        });
        return;
      }
      
      final heartRate = healthData['heartRate'] as int?;
      final spo2 = healthData['spo2'] as int?;
      final steps = healthData['steps'] as int;
      
      setState(() {
        _currentHeartRate = heartRate;
        _hasPermission = true;
        
        // Calculate risk level based on heart rate
        _riskLevel = _calculateRiskLevel(heartRate);
        
        // Generate AI insight based on real data
        _aiInsight = _generateAIInsight(heartRate, spo2, steps);
        
        _isLoading = false;
      });
      
      // Load average heart rate (you'll need to implement this in HealthService)
      await _loadAverageHeartRate();
      
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _aiInsight = 'Unable to fetch health data. Please check your connection.';
      });
      print('Error loading health data: $e');
    }
  }
  
  Future<void> _loadAverageHeartRate() async {
    try {
      // Fetch last 7 days of heart rate data
      final avgHeartRate = await _healthService.fetchAverageHeartRate(days: 7);
      setState(() {
        _averageHeartRate = avgHeartRate;
      });
    } catch (e) {
      print('Error loading average heart rate: $e');
      setState(() {
        _averageHeartRate = _currentHeartRate; // Fallback to current
      });
    }
  }
  
  String _calculateRiskLevel(int? heartRate) {
    if (heartRate == null) return '--';
    
    if (heartRate < 60) {
      return 'Low (Bradycardia)';
    } else if (heartRate >= 60 && heartRate <= 100) {
      return 'Normal';
    } else if (heartRate > 100 && heartRate <= 120) {
      return 'Elevated';
    } else if (heartRate > 120) {
      return 'High (Tachycardia)';
    }
    return '--';
  }
  
  String _generateAIInsight(int? heartRate, int? spo2, int steps) {
    if (heartRate == null) {
      return 'Unable to fetch health data. Please check your permissions and try again.';
    }
    
    List<String> insights = [];
    
    // Heart rate insight
    if (heartRate < 60) {
      insights.add('Your heart rate is below normal range (${heartRate}bpm). Consider consulting a healthcare provider.');
    } else if (heartRate >= 60 && heartRate <= 100) {
      insights.add('Your heart rate is normal at ${heartRate}bpm. Keep up the good work!');
    } else if (heartRate > 100 && heartRate <= 120) {
      insights.add('Your heart rate is slightly elevated (${heartRate}bpm). Try relaxation techniques.');
    } else if (heartRate > 120) {
      insights.add('Your heart rate is high (${heartRate}bpm). Please rest and consult a doctor if persistent.');
    }
    
    // SpO2 insight
    if (spo2 != null) {
      if (spo2 >= 95) {
        insights.add('Blood oxygen levels are excellent at ${spo2}%.');
      } else if (spo2 >= 90 && spo2 < 95) {
        insights.add('Blood oxygen is at ${spo2}%. Monitor your breathing.');
      } else if (spo2 < 90) {
        insights.add('Low blood oxygen (${spo2}%). Please seek medical attention.');
      }
    }
    
    // Steps insight
    if (steps > 0) {
      if (steps >= 10000) {
        insights.add('Great job reaching ${steps} steps today! You\'re very active.');
      } else if (steps >= 5000) {
        insights.add('You\'ve taken ${steps} steps today. Aim for 10,000 steps!');
      } else if (steps > 0) {
        insights.add('You\'ve taken ${steps} steps today. Try to increase your daily activity.');
      }
    }
    
    if (insights.isEmpty) {
      return 'Your health data is being analyzed. Check back soon for personalized insights.';
    }
    
    return insights.join(' ');
  }

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
    return RefreshIndicator(
      onRefresh: _loadHealthData,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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

              // Error Message if any
              if (_errorMessage != null && !_hasPermission)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              if (_errorMessage != null && !_hasPermission)
                const SizedBox(height: 20),

              // Three Health Cards
              Row(
                children: [
                  Expanded(
                    child: HealthCard(
                      title: 'Current HR',
                      value: _isLoading ? '--' : '${_currentHeartRate ?? "--"}',
                      unit: 'bpm',
                      icon: Icons.favorite,
                      color: AppColors.primaryDeep,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: HealthCard(
                      title: 'Average HR',
                      value: _isLoading ? '--' : '${_averageHeartRate ?? "--"}',
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
                      color: _getRiskColor(_riskLevel),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Last Updated Time
              if (!_isLoading && _currentHeartRate != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.timer,
                      size: 12,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Updated just now',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 16),

              // AI Insight Section
              AIInsightCard(
                insight: _aiInsight,
                isLoading: _isLoading,
                onRefresh: _loadHealthData,
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
      ),
    );
  }
  
  Color _getRiskColor(String riskLevel) {
    if (riskLevel.contains('Normal')) return AppColors.success;
    if (riskLevel.contains('Low')) return Colors.orange;
    if (riskLevel.contains('Elevated')) return Colors.orange;
    if (riskLevel.contains('High')) return AppColors.error;
    return AppColors.success;
  }
}