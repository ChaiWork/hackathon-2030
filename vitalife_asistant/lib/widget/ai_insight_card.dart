import 'package:flutter/material.dart';

class AIInsightCard extends StatelessWidget {
  final String insight;
  final bool isLoading;
  final VoidCallback onRefresh;

  const AIInsightCard({
    super.key,
    required this.insight,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.3),
            Colors.purple.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                "AI Health Insight",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (!isLoading)
                IconButton(
                  onPressed: onRefresh,
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white54,
                    size: 18,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else
            Text(
              insight,
              style: TextStyle(
                color: Colors.white70,
                fontSize: isSmallScreen ? 12 : 14,
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }
}
