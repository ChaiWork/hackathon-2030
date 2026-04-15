import 'package:flutter/material.dart';
import 'package:vitalife_asistant/screens/widgets_screen/auth_screen_widget/_auth_text_field.dart';
import 'package:vitalife_asistant/screens/widgets_screen/auth_screen_widget/_transparent_3d_button.dart';


class SignUpForm extends StatefulWidget {
  final AnimationController animationController;

  const SignUpForm({
    super.key,
    required this.animationController,
  });

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Full Name Input
          AuthTextField(
            controller: _nameController,
            hint: 'Full Name',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 20),

          // Email Input
          AuthTextField(
            controller: _emailController,
            hint: 'Email Address',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),

          // Password Input
          AuthTextField(
            controller: _passwordController,
            hint: 'Password',
            icon: Icons.lock_outline,
            isPassword: true,
            obscurePassword: _obscurePassword,
            onPasswordToggle: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
          ),
          const SizedBox(height: 20),

          // Confirm Password Input
          AuthTextField(
            controller: _confirmPasswordController,
            hint: 'Confirm Password',
            icon: Icons.lock_outline,
            isPassword: true,
            obscurePassword: _obscureConfirmPassword,
            onPasswordToggle: () {
              setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
            },
          ),

          const SizedBox(height: 32),

          // Sign Up Button
          Transparent3DButton(
            label: 'SIGN UP',
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/home');
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}