import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vitalife_asistant/screens/widgets_screen/auth_screen_widget/_auth_text_field.dart';
import 'package:vitalife_asistant/screens/widgets_screen/auth_screen_widget/_transparent_3d_button.dart';

class LoginForm extends StatefulWidget {
  final AnimationController animationController;

  const LoginForm({super.key, required this.animationController});

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
  void initState() {
    super.initState();
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      await GoogleSignIn.instance.initialize();
      print('Google Sign-In initialized successfully');
    } catch (e) {
      print('Google Sign-In initialization error: $e');
    }
  }

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

          const SizedBox(height: 20),

          // OR Divider
          const Row(
            children: [
              Expanded(child: Divider(color: Colors.white30)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
              Expanded(child: Divider(color: Colors.white30)),
            ],
          ),

          const SizedBox(height: 20),

          // Google Sign In Button
          _buildGoogleSignInButton(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleGoogleSignIn,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(0, 5),
              blurRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Google Logo
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(
                  Icons.g_mobiledata,
                  size: 20,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _isLoading ? 'SIGNING IN...' : 'CONTINUE WITH GOOGLE',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
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
      await _auth.signInWithEmailAndPassword(email: email, password: password);
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

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      // Check if platform supports authenticate
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        _showMessage('Google Sign-In not supported on this platform');
        return;
      }

      // Start interactive sign-in process
      final GoogleSignInAccount? googleUser = 
          await GoogleSignIn.instance.authenticate();

      if (googleUser == null) {
        if (mounted) {
          _showMessage('Google Sign-In cancelled');
        }
        return;
      }

      // Get authentication tokens
      final GoogleSignInAuthentication googleAuth = 
          googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        
      );

      // Sign in to Firebase
      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);

      if (!mounted) return;
      
      _showMessage('Welcome ${userCredential.user?.displayName ?? "User"}!');
      Navigator.of(context).pushReplacementNamed('/home');
      
    } on GoogleSignInException catch (e) {
      print('Google Sign-In Exception: ${e.code} - ${e.description}');
      _showMessage('Google Sign-In failed: ${e.description}');
    } on FirebaseAuthException catch (e) {
      _showMessage(_friendlyAuthMessage(e));
    } catch (e) {
      print('Unexpected error: $e');
      _showMessage('Google Sign-In failed. Please try again.');
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
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in method.';
      default:
        return e.message ?? 'Authentication error.';
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}