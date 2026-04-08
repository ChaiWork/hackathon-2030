import 'dart:convert';
import 'package:flutter/material.dart';
import 'custom_containers/SymptomResultContainer.dart';

class ResultScreen extends StatelessWidget {
  final String symptoms;
  final String result;

  const ResultScreen({super.key, required this.symptoms, required this.result});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = jsonDecode(result);

    String risk = data["risk"];
    String reason = data["reason"];
    String recommendation = data["recommendation"];

    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 600;
    final isDesktop = screenSize.width >= 1024;

    // Responsive padding and spacing
    final horizontalPadding = screenSize.width * 0.05;
    final verticalSpacing = screenSize.height * 0.03;
    final titleFontSize = isTablet ? 22.0 : 18.0;
    final symptomsFontSize = isTablet ? 18.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Result"),
        centerTitle: false,
        toolbarHeight: isTablet ? 80 : 56,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Symptoms section with responsive container
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isTablet ? 20 : 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(
                            isTablet ? 16 : 12,
                          ),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Symptoms Entered:",
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            SizedBox(height: verticalSpacing * 0.5),
                            Text(
                              symptoms,
                              style: TextStyle(
                                fontSize: symptomsFontSize,
                                height: 1.5,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: verticalSpacing),

                      // Responsive SymptomResultContainer
                      Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          maxWidth: isDesktop ? 800 : double.infinity,
                        ),
                        child: SymptomResultContainer(
                          riskLevel: risk,
                          reason: reason,
                          recommendation: recommendation,
                        ),
                      ),

                      SizedBox(height: verticalSpacing * 1.5),

                      // Responsive button section
                      if (isDesktop)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 300,
                              child: _buildActionButton(context),
                            ),
                          ],
                        )
                      else
                        _buildActionButton(context),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final buttonHeight = screenSize.height * 0.06;
    final buttonFontSize = screenSize.width * 0.04;

    return SizedBox(
      width: double.infinity,
      height: buttonHeight.clamp(44.0, 60.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          "Check Another Symptom",
          style: TextStyle(
            fontSize: buttonFontSize.clamp(14.0, 18.0),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
