import 'package:flutter/material.dart';
import 'package:vitalife_asistant/screens/widgets_screen/auth_screen_widget/_auth_tab_bar.dart';
import 'package:vitalife_asistant/screens/widgets_screen/auth_screen_widget/_gradient_background.dart';
import 'package:vitalife_asistant/screens/widgets_screen/auth_screen_widget/_login_form.dart';
import 'package:vitalife_asistant/screens/widgets_screen/auth_screen_widget/_logo_section.dart';
import 'package:vitalife_asistant/screens/widgets_screen/auth_screen_widget/_signup_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _selectedTab = 0; // 0 for Login, 1 for Sign Up

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Logo Section
              const LogoSection(),

              // Tab Buttons Section
              AuthTabBar(
                selectedTab: _selectedTab,
                onTabChanged: (index) {
                  setState(() => _selectedTab = index);
                  if (index == 0) {
                    _animationController.forward();
                  } else {
                    _animationController.reverse();
                  }
                },
              ),

              const SizedBox(height: 48),

              // Content Section with PageView-like animation
              Expanded(
                child: IndexedStack(
                  index: _selectedTab,
                  children: [
                    LoginForm(animationController: _animationController),
                    SignUpForm(animationController: _animationController),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
