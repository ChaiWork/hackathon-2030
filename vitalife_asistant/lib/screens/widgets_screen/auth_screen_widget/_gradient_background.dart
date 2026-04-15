import 'package:flutter/material.dart';
import 'package:vitalife_asistant/screens/constant/Color.dart';


class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLight,
            AppColors.primaryMedium,
            AppColors.primaryDark,
            AppColors.primaryDeep,
          ],
          stops: const [0.0, 0.33, 0.66, 1.0],
        ),
      ),
      child: child,
    );
  }
}