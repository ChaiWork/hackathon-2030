import 'package:flutter/material.dart';
import 'package:vitalife_asistant/widget/add_measurement_dialog.dart';
import 'package:vitalife_asistant/widget/bar.dart';
import 'package:vitalife_asistant/widget/healthCard.dart';
import 'package:vitalife_asistant/widget/bottomnavbar.dart';

class HealthDashboard extends StatefulWidget {
  const HealthDashboard({super.key});

  @override
  State<HealthDashboard> createState() => _HealthDashboardState();
}

class _HealthDashboardState extends State<HealthDashboard> {
  // Data for the graph - now using a map with day keys
  Map<String, double> systolicReadings = {
    "Mon": 120,
    "Tue": 180,
    "Wed": 200,
    "Thu": 10,
    "Fri": 90,
    "Sat": 50,
    "Sun": 130,
  };

  List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  // Health metrics data
  String bloodPressure = "142/90";
  String heartRate = "78 bpm";
  String bloodGlucose = "6.8 mmol";
  String spo2 = "98 %";

  // Latest readings for tracking
  List<Map<String, dynamic>> allReadings = [];

  int _selectedNavIndex = 0; // Track selected navigation item

  @override
  void initState() {
    super.initState();
    // Add initial reading to history
    _addToHistory(142, 90, 78, 6.8, 98);
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
          onPressed: () => _showAddMeasurementDialog(context),
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
                      /// Header
                      Row(
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
                                      : (isTablet ? 28 : 32),
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
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 18,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      /// Alert Box (shows warning if blood pressure is high)
                      if (_isBloodPressureHigh(bloodPressure))
                        Container(
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
                              Icon(
                                Icons.warning,
                                color: Colors.red,
                                size: isSmallScreen ? 20 : 24,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Blood pressure elevated - Check doctor",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 12 : 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 25),

                      /// Health Cards Grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: isSmallScreen ? 2 : (isTablet ? 3 : 4),
                        mainAxisSpacing: isSmallScreen ? 12 : 16,
                        crossAxisSpacing: isSmallScreen ? 12 : 16,
                        childAspectRatio: isSmallScreen
                            ? 1.2
                            : (isTablet ? 1.3 : 1.4),
                        children: [
                          healthCard(
                            "❤️",
                            bloodPressure,
                            "Blood Pressure",
                            _getBloodPressureColor(bloodPressure),
                            isSmallScreen,
                          ),
                          healthCard(
                            "💓",
                            heartRate,
                            "Heart Rate",
                            _getHeartRateColor(heartRate),
                            isSmallScreen,
                          ),
                          healthCard(
                            "🩸",
                            bloodGlucose,
                            "Blood Glucose",
                            _getGlucoseColor(bloodGlucose),
                            isSmallScreen,
                          ),
                          healthCard(
                            "🫁",
                            spo2,
                            "SpO₂",
                            _getSpO2Color(spo2),
                            isSmallScreen,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// Risk Graph Container
                      /// Risk Graph Container
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B263B),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "7-DAY BLOOD PRESSURE TREND",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: isSmallScreen ? 12 : 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _showAllReadings,
                                  child: Text(
                                    "View All",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: isSmallScreen ? 10 : 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 5),

                            const SizedBox(height: 5),
                            SizedBox(
                              height: isSmallScreen
                                  ? 200
                                  : 160, // Increased height for better visualization
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: days.map((day) {
                                  double systolicValue =
                                      systolicReadings[day] ?? 0;
                                  double barHeight = _calculateBarHeight(
                                    systolicValue,
                                  );
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // Value label
                                      if (systolicValue > 0)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 4,
                                          ),
                                          child: Text(
                                            '${systolicValue.toInt()}',
                                            style: TextStyle(
                                              color: _getBarColor(
                                                systolicValue,
                                              ),
                                              fontSize: isSmallScreen ? 10 : 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      // Bar
                                      Container(
                                        width: isSmallScreen ? 12 : 20,
                                        height: barHeight,
                                        decoration: BoxDecoration(
                                          color: _getBarColor(systolicValue),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Day labels with current day indicator
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: days.map((day) {
                                final isToday = _isToday(day);
                                return Column(
                                  children: [
                                    Text(
                                      day,
                                      style: TextStyle(
                                        color: isToday
                                            ? Colors.blue
                                            : Colors.white54,
                                        fontSize: isSmallScreen ? 10 : 12,
                                        fontWeight: isToday
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    if (isToday)
                                      Container(
                                        margin: const EdgeInsets.only(top: 2),
                                        width: 4,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                );
                              }).toList(),
                            ),
                            // Add reference line indicators
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 2,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "High",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: isSmallScreen ? 8 : 10,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 2,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Normal",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: isSmallScreen ? 8 : 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      /// Latest Readings Section
                      if (allReadings.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Container(
                            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B263B),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "RECENT READINGS",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: isSmallScreen ? 12 : 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 100,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: allReadings.length > 5
                                        ? 5
                                        : allReadings.length,
                                    itemBuilder: (context, index) {
                                      final reading =
                                          allReadings[allReadings.length -
                                              1 -
                                              index];
                                      return Container(
                                        width: 120,
                                        margin: const EdgeInsets.only(
                                          right: 10,
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0D1B2A),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              reading['date'],
                                              style: const TextStyle(
                                                color: Colors.white54,
                                                fontSize: 10,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              "BP: ${reading['systolic']}/${reading['diastolic']}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              "HR: ${reading['heartRate']} bpm",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            /// Bottom Navigation Bar
            Padding(
              padding: EdgeInsets.only(
                bottom: isSmallScreen ? 10 : 16,
                left: isSmallScreen ? 10 : 16,
                right: isSmallScreen ? 10 : 16,
              ),
              child: BottomNavBar(
                currentIndex: _selectedNavIndex,
                onTap: (index) {
                  setState(() {
                    _selectedNavIndex = index;
                  });
                  // Handle navigation based on index
                  switch (index) {
                    case 0:
                      // Home
                      break;
                    case 1:
                      // Chart/Statistics
                      _showStatisticsDialog();
                      break;
                    case 2:
                      // Medications
                      break;
                    case 3:
                      // AI Assistant
                      break;
                    case 4:
                      // Profile
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

  /// Show popup dialog to add new measurements
  void _showAddMeasurementDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AddMeasurementDialog(
          onSave: (Map<String, dynamic> data) {
            // Handle the saved data
            setState(() {
              // Update blood pressure
              bloodPressure = "${data['systolic']}/${data['diastolic']}";

              // Update heart rate
              heartRate = "${data['heartRate']} bpm";

              // Update blood glucose
              bloodGlucose = "${data['glucose']} mmol";

              // Update SpO2
              spo2 = "${data['spo2']} %";

              // Update systolic reading for TODAY only
              String today = _getCurrentDay();
              systolicReadings[today] = data['systolic'].toDouble();

              // Add to history
              _addToHistory(
                data['systolic'],
                data['diastolic'],
                data['heartRate'],
                data['glucose'],
                data['spo2'],
              );

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Measurements added successfully!"),
                  backgroundColor: Colors.green,
                ),
              );
            });
          },
        );
      },
    );
  }

  String _getCurrentDay() {
    final now = DateTime.now();
    // Convert DateTime weekday (1 = Monday, 7 = Sunday) to our day strings
    switch (now.weekday) {
      case 1:
        return "Mon";
      case 2:
        return "Tue";
      case 3:
        return "Wed";
      case 4:
        return "Thu";
      case 5:
        return "Fri";
      case 6:
        return "Sat";
      case 7:
        return "Sun";
      default:
        return "Mon";
    }
  }

  bool _isToday(String day) {
    return day == _getCurrentDay();
  }

  void _addToHistory(
    int systolic,
    int diastolic,
    int heartRate,
    double glucose,
    int spo2,
  ) {
    allReadings.add({
      'date': _getCurrentDate(),
      'day': _getCurrentDay(),
      'systolic': systolic,
      'diastolic': diastolic,
      'heartRate': heartRate,
      'glucose': glucose,
      'spo2': spo2,
    });
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return "${now.day}/${now.month}/${now.year}";
  }

  void _showAllReadings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("All Blood Pressure Readings"),
          content: Container(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: allReadings.length,
              itemBuilder: (context, index) {
                final reading = allReadings[allReadings.length - 1 - index];
                return ListTile(
                  title: Text(
                    "${reading['date']} (${reading['day']}): ${reading['systolic']}/${reading['diastolic']}",
                  ),
                  subtitle: Text(
                    "HR: ${reading['heartRate']} bpm | Glucose: ${reading['glucose']} mmol | SpO2: ${reading['spo2']}%",
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

  void _showStatisticsDialog() {
    if (allReadings.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No data available yet")));
      return;
    }

    // Calculate statistics
    double avgSystolic =
        allReadings
            .map((e) => e['systolic'].toDouble())
            .reduce((a, b) => a + b) /
        allReadings.length;
    double avgDiastolic =
        allReadings
            .map((e) => e['diastolic'].toDouble())
            .reduce((a, b) => a + b) /
        allReadings.length;
    double avgHeartRate =
        allReadings
            .map((e) => e['heartRate'].toDouble())
            .reduce((a, b) => a + b) /
        allReadings.length;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Health Statistics"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Average Systolic: ${avgSystolic.toStringAsFixed(1)}"),
              const SizedBox(height: 5),
              Text("Average Diastolic: ${avgDiastolic.toStringAsFixed(1)}"),
              const SizedBox(height: 5),
              Text(
                "Average Heart Rate: ${avgHeartRate.toStringAsFixed(1)} bpm",
              ),
              const SizedBox(height: 5),
              Text("Total Readings: ${allReadings.length}"),
            ],
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

  bool _isBloodPressureHigh(String bp) {
    try {
      final parts = bp.split('/');
      if (parts.length == 2) {
        final systolic = int.parse(parts[0]);
        return systolic > 130;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  Color _getBloodPressureColor(String bp) {
    try {
      final parts = bp.split('/');
      if (parts.length == 2) {
        final systolic = int.parse(parts[0]);
        if (systolic < 120) return Colors.green;
        if (systolic < 130) return Colors.orange;
        return Colors.red;
      }
    } catch (e) {
      return Colors.red;
    }
    return Colors.red;
  }

  Color _getHeartRateColor(String hr) {
    try {
      final value = int.parse(hr.split(' ')[0]);
      if (value >= 60 && value <= 100) return Colors.green;
      return Colors.orange;
    } catch (e) {
      return Colors.green;
    }
  }

  Color _getGlucoseColor(String glucose) {
    try {
      final value = double.parse(glucose.split(' ')[0]);
      if (value >= 4.0 && value <= 7.0) return Colors.green;
      return Colors.orange;
    } catch (e) {
      return Colors.orange;
    }
  }

  Color _getSpO2Color(String spo2Value) {
    try {
      final value = int.parse(spo2Value.split(' ')[0]);
      if (value >= 95) return Colors.green;
      return Colors.orange;
    } catch (e) {
      return Colors.green;
    }
  }

  /// Get color based on blood pressure value
  Color _getBarColor(double value) {
    // Systolic Blood Pressure categories
    if (value < 120) return Colors.green; // Optimal/Normal - GOOD
    if (value < 130) return Colors.lightGreen; // Elevated but acceptable
    if (value < 140) return Colors.orange; // High Normal - CAUTION
    if (value < 160) return Colors.deepOrange; // Hypertension Stage 1 - HIGH
    return Colors.red; // Hypertension Stage 2 - VERY HIGH
  }
}

/// Calculate bar height based on systolic value
/// Scale: 80 mmHg = 20px (low bar - good)
///        120 mmHg = 60px (medium bar - normal)
///        140 mmHg = 100px (high bar - elevated)
///        180 mmHg = 140px (very high bar - dangerous)
double _calculateBarHeight(double systolicValue) {
  if (systolicValue <= 0) return 0;

  // Min height for very low BP (80 mmHg)
  const minHeight = 20.0;
  // Max height for very high BP (180+ mmHg)
  const maxHeight = 140.0;
  // Min reference value (80 mmHg)
  const minValue = 80.0;
  // Max reference value (180 mmHg)
  const maxValue = 180.0;

  // Clamp value between min and max
  double clampedValue = systolicValue.clamp(minValue, maxValue);

  // Linear interpolation formula
  double height =
      minHeight +
      (clampedValue - minValue) *
          (maxHeight - minHeight) /
          (maxValue - minValue);

  return height;
}
