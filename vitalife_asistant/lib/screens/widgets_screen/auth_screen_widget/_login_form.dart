import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitalife_asistant/screens/widgets_screen/auth_screen_widget/_auth_text_field.dart';
import 'package:vitalife_asistant/screens/widgets_screen/auth_screen_widget/_transparent_3d_button.dart';


class LoginForm extends StatefulWidget {
  final AnimationController animationController;

  const LoginForm({
    super.key,
    required this.animationController,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Email Input
          AuthTextField(
            controller: _emailController,
            hint: 'Email Address',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),

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

          const SizedBox(height: 32),

          // Login Button
          Transparent3DButton(
            label: _isLoading ? 'LOGGING IN...' : 'LOGIN',
            onPressed: _isLoading ? () {} : _handleLogin,
          ),

          const SizedBox(height: 20),

          // Forgot Password Link
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password recovery coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Text(
              'Forgot Password?',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter email and password.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } on FirebaseAuthException catch (e) {
      _showMessage(_friendlyAuthMessage(e));
    } catch (_) {
      _showMessage('Login failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyAuthMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'Authentication error.';
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}