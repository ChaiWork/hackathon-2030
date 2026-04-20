import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitalife_asistant/ui/responsive.dart';

class ConnectionStatus extends StatelessWidget {
  final bool isConnected;

  const ConnectionStatus({
    super.key,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final padV = r.gapV(0.01, min: 6, max: 10);
    final labelFont = r.s(14, min: 12, max: 15);
    final pillFont = r.s(12, min: 11, max: 13);
    final pillPadH = r.s(12, min: 10, max: 14);
    final pillPadV = r.s(6, min: 5, max: 8);
    final pillRadius = r.s(20, min: 16, max: 22);
    final dotSize = r.s(8, min: 7, max: 9);
    final dotGap = r.s(6, min: 5, max: 8);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: padV),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Status',
            style: GoogleFonts.montserrat(
              fontSize: labelFont,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: pillPadH, vertical: pillPadV),
            decoration: BoxDecoration(
              color: isConnected ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(pillRadius),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  size: dotSize,
                  color: isConnected ? Colors.green : Colors.red,
                ),
                SizedBox(width: dotGap),
                Text(
                  isConnected ? 'Connected' : 'Not Connected',
                  style: GoogleFonts.montserrat(
                    fontSize: pillFont,
                    fontWeight: FontWeight.w600,
                    color: isConnected ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}