import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vitalife_asistant/screens/widgets_screen/auth_screen_widget/_auth_text_field.dart';
import 'package:vitalife_asistant/screens/widgets_screen/auth_screen_widget/_transparent_3d_button.dart';
import 'package:vitalife_asistant/ui/responsive.dart';

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
    final r = Responsive.of(context);
    final padH = r.gapH(0.06, min: 16, max: 28);
    final sectionGap = r.gapV(0.025, min: 16, max: 32);
    final smallGap = r.gapV(0.018, min: 12, max: 24);
    final footerGap = r.gapV(0.05, min: 28, max: 40);
    final linkFont = r.s(14, min: 12, max: 14);
    final dividerTextFont = r.s(12, min: 11, max: 12);
    final googleBtnH = r.s(55, min: 48, max: 60);
    final googleLogo = r.s(24, min: 20, max: 26);
    final googleIcon = r.s(20, min: 18, max: 22);
    final googleGap = r.gapH(0.03, min: 8, max: 12);
    final googleFont = r.s(14, min: 12, max: 14);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: padH),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            children: [
              // Email Input
              AuthTextField(
                controller: _emailController,
                hint: 'Email Address',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: smallGap),

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

              SizedBox(height: sectionGap),

              // Login Button
              Transparent3DButton(
                label: _isLoading ? 'LOGGING IN...' : 'LOGIN',
                onPressed: _isLoading ? () {} : _handleLogin,
              ),

              SizedBox(height: r.gapV(0.02, min: 14, max: 20)),

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
                    fontSize: linkFont,
                    color: Colors.white70,
                  ),
                ),
              ),

              SizedBox(height: r.gapV(0.02, min: 14, max: 20)),

              // OR Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: Colors.white30)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: googleGap),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: dividerTextFont,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: Colors.white30)),
                ],
              ),

              SizedBox(height: r.gapV(0.02, min: 14, max: 20)),

              // Google Sign In Button
              GestureDetector(
                onTap: _isLoading ? null : _handleGoogleSignIn,
                child: Container(
                  height: googleBtnH,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.white, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(r.s(15, min: 12, max: 16)),
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
                        Container(
                          width: googleLogo,
                          height: googleLogo,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Icon(
                            Icons.g_mobiledata,
                            size: googleIcon,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(width: googleGap),
                        Flexible(
                          child: Text(
                            _isLoading
                                ? 'SIGNING IN...'
                                : 'CONTINUE WITH GOOGLE',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              fontSize: googleFont,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              letterSpacing: r.s(1.2, min: 1.0, max: 1.2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: footerGap),
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