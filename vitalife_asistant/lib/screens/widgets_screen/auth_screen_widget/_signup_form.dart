import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vitalife_asistant/screens/widgets_screen/auth_screen_widget/_auth_text_field.dart';
import 'package:vitalife_asistant/screens/widgets_screen/auth_screen_widget/_transparent_3d_button.dart';
import 'package:vitalife_asistant/ui/responsive.dart';


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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

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
    final r = Responsive.of(context);
    final padH = r.gapH(0.06, min: 16, max: 28);
    final fieldGap = r.gapV(0.02, min: 12, max: 20);
    final sectionGap = r.gapV(0.025, min: 16, max: 32);
    final footerGap = r.gapV(0.05, min: 28, max: 40);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: padH),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            children: [
              // Full Name Input
              AuthTextField(
                controller: _nameController,
                hint: 'Full Name',
                icon: Icons.person_outline,
              ),
              SizedBox(height: fieldGap),

              // Email Input
              AuthTextField(
                controller: _emailController,
                hint: 'Email Address',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: fieldGap),

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
              SizedBox(height: fieldGap),

              // Confirm Password Input
              AuthTextField(
                controller: _confirmPasswordController,
                hint: 'Confirm Password',
                icon: Icons.lock_outline,
                isPassword: true,
                obscurePassword: _obscureConfirmPassword,
                onPasswordToggle: () {
                  setState(() =>
                      _obscureConfirmPassword = !_obscureConfirmPassword);
                },
              ),

              SizedBox(height: sectionGap),

              // Sign Up Button
              Transparent3DButton(
                label: _isLoading ? 'CREATING...' : 'SIGN UP',
                onPressed: _isLoading ? () {} : _handleSignUp,
              ),
              SizedBox(height: footerGap),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showMessage('Please fill in all fields.');
      return;
    }
    if (password != confirmPassword) {
      _showMessage('Passwords do not match.');
      return;
    }
    if (password.length < 6) {
      _showMessage('Password must be at least 6 characters.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } on FirebaseAuthException catch (e) {
      _showMessage(_friendlyAuthMessage(e));
    } catch (_) {
      _showMessage('Sign up failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyAuthMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      case 'weak-password':
        return 'Password is too weak.';
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