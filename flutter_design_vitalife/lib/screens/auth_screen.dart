import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Color Palette
const Color _color1 = Color(0xFFE7ECFF);
const Color _color2 = Color(0xFFD8E1FF);
const Color _color3 = Color(0xFFBBD0FF);
const Color _color4 = Color(0xFFA8BCFB);
const Color _color5 = Color(0xFF7EA0EA);

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_color1, _color2, _color3, _color5],
            stops: [0.0, 0.33, 0.66, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Logo & Title Section
              const SizedBox(height: 40),
              Image.asset(
                'assets/images/vitalife_logo.png',
                height: 190,
                width: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              
              // Tab Buttons Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedTab = 0);
                          _animationController.forward();
                        },
                        child: Column(
                          children: [
                            Text(
                              'LOGIN',
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: _selectedTab == 0
                                    ? Colors.white
                                    : Colors.white60,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_selectedTab == 0)
                              Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedTab = 1);
                          _animationController.reverse();
                        },
                        child: Column(
                          children: [
                            Text(
                              'SIGN UP',
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: _selectedTab == 1
                                    ? Colors.white
                                    : Colors.white60,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_selectedTab == 1)
                              Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Content Section with PageView-like animation
              Expanded(
                child: IndexedStack(
                  index: _selectedTab,
                  children: [
                    _LoginForm(
                      animationController: _animationController,
                    ),
                    _SignUpForm(
                      animationController: _animationController,
                    ),
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

class _LoginForm extends StatefulWidget {
  final AnimationController animationController;

  const _LoginForm({required this.animationController});

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

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
          _buildTextField(
            controller: _emailController,
            hint: 'Email Address',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),

          // Password Input
          _buildTextField(
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

          // Login Button with 3D effect
          _buildTransparent3DButton(
            label: 'LOGIN',
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/home');
            },
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
}

class _SignUpForm extends StatefulWidget {
  final AnimationController animationController;

  const _SignUpForm({required this.animationController});

  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
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
          _buildTextField(
            controller: _nameController,
            hint: 'Full Name',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 20),

          // Email Input
          _buildTextField(
            controller: _emailController,
            hint: 'Email Address',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),

          // Password Input
          _buildTextField(
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
          _buildTextField(
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

          const SizedBox(height: 32),

          // Sign Up Button with 3D effect
          _buildTransparent3DButton(
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

// Transparent 3D Button Widget
Widget _buildTransparent3DButton({
  required String label,
  required VoidCallback onPressed,
}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // Gradient border effect
        gradient: const LinearGradient(
          colors: [_color3, _color4],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.5),
          // Transparent background with backdrop blur effect
          color: Colors.white.withOpacity(0.1),
        ),
        child: Stack(
          children: [
            // 3D Shadow Effect
            Positioned(
              bottom: -2,
              left: 0,
              right: 0,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(14.5),
                  ),
                  color: Colors.black.withOpacity(0.15),
                ),
              ),
            ),
            // Button Content
            Center(
              child: Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Reusable Text Field Widget
Widget _buildTextField({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  TextInputType keyboardType = TextInputType.text,
  bool isPassword = false,
  bool obscurePassword = false,
  VoidCallback? onPasswordToggle,
}) {
  return Container(
    height: 56,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      // Gradient border
      gradient: const LinearGradient(
        colors: [_color3, _color4],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Container(
      margin: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.5),
        color: Colors.white.withOpacity(0.12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword ? obscurePassword : false,
        style: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          hintText: hint,
          hintStyle: GoogleFonts.montserrat(
            color: Colors.white.withOpacity(0.6),
            fontSize: 15,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              icon,
              color: Colors.white.withOpacity(0.7),
              size: 22,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0),
          suffixIcon: isPassword
              ? GestureDetector(
                  onTap: onPasswordToggle,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.white.withOpacity(0.7),
                      size: 22,
                    ),
                  ),
                )
              : null,
        ),
      ),
    ),
  );
}
