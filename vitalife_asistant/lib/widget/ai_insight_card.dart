import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// AIInsightCard component (customized to match the original design)

// Color Palette

const Color _color2 = Color(0xFFD8E1FF);
const Color _color3 = Color(0xFFBBD0FF);

const Color _color5 = Color(0xFF7EA0EA);

class AIInsightCard1 extends StatelessWidget {
  final String insight;
  final bool isLoading;
  final VoidCallback onRefresh;

  const AIInsightCard1({
    super.key,
    required this.insight,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.9), _color2.withOpacity(0.5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: _color3.withOpacity(0.3), width: 1.5),
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _color5.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome, color: _color5, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'AI Diagnosis',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _color5,
                ),
              ),
              const Spacer(),
              if (!isLoading)
                IconButton(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh, color: _color5, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(_color5),
                ),
              ),
            )
          else
            Text(
              insight,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Powered by Gemini AI',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: Colors.blue[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
