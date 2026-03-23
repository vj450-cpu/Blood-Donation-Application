// lib/screens/auth_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:google_fonts/google_fonts.dart';
import '../screens/home_screen.dart';

// --- AUTHENTICATION LOGIC CLASS ---
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> registerWithEmail(String email, String password, String name) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(name.trim()); 
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("Email Registration Error: ${e.message}");
      return null;
    }
  }
  
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("Email Sign-In Error: ${e.message}");
      return null;
    }
  }
}

// --- UI WIDGET ---
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  
  bool _isLogin = true; 
  bool _isLoading = false;
  
  final Color primaryRed = const Color(0xFFD32F2F); 
  final Color darkRed = const Color(0xFFC62828);
  final Color navyContrast = const Color(0xFF2C3E50);
  
  late AnimationController _heartbeatController;
  late Animation<double> _heartbeatScaleAnimation;

  late AnimationController _gradientController;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  @override
  void initState() {
    super.initState();
    
    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _heartbeatScaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _heartbeatController, curve: Curves.easeInOut)
    );

    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), 
    )..repeat();
    
    _topAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem<Alignment>(tween: Tween(begin: Alignment.topLeft, end: Alignment.topRight), weight: 1),
      TweenSequenceItem<Alignment>(tween: Tween(begin: Alignment.topRight, end: Alignment.bottomRight), weight: 1),
      TweenSequenceItem<Alignment>(tween: Tween(begin: Alignment.bottomRight, end: Alignment.bottomLeft), weight: 1),
      TweenSequenceItem<Alignment>(tween: Tween(begin: Alignment.bottomLeft, end: Alignment.topLeft), weight: 1),
    ]).animate(_gradientController);
    
    _bottomAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem<Alignment>(tween: Tween(begin: Alignment.bottomRight, end: Alignment.bottomLeft), weight: 1),
      TweenSequenceItem<Alignment>(tween: Tween(begin: Alignment.bottomLeft, end: Alignment.topLeft), weight: 1),
      TweenSequenceItem<Alignment>(tween: Tween(begin: Alignment.topLeft, end: Alignment.topRight), weight: 1),
      TweenSequenceItem<Alignment>(tween: Tween(begin: Alignment.topRight, end: Alignment.bottomRight), weight: 1),
    ]).animate(_gradientController);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _heartbeatController.dispose();
    _gradientController.dispose(); 
    super.dispose();
  }
  
  void _showForgotPasswordDialog() {
    final TextEditingController resetEmail = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Reset Password', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter the email associated with your account. We will send a password reset link.', style: GoogleFonts.montserrat(fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: resetEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.montserrat(color: darkRed))),
          TextButton(
            onPressed: () async {
              final email = resetEmail.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Enter a valid email', style: GoogleFonts.montserrat())));
                return;
              }
              Navigator.pop(context);
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password reset link sent to $email', style: GoogleFonts.montserrat())));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send reset email: $e', style: GoogleFonts.montserrat())));
              }
            },
            child: Text('Send', style: GoogleFonts.montserrat(color: darkRed)),
          ),
        ],
      ),
    );
  }

  void _submitAuthForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_isLogin && _nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter your full name.', style: GoogleFonts.montserrat())),
        );
        return;
    }
    
    setState(() => _isLoading = true);
    
    User? user;
    String successMessage = "";
    String errorMessage = 'Authentication Failed. Please check credentials.';

    try {
      if (_isLogin) {
        user = await _authService.signInWithEmail(_emailController.text, _passwordController.text);
        successMessage = "Welcome back!";
      } else {
        user = await _authService.registerWithEmail(
          _emailController.text, 
          _passwordController.text,
          _nameController.text, 
        );
        successMessage = "Registration successful! Name saved.";
      }

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage, style: GoogleFonts.montserrat())),
        );

        // ✅ FIXED: Navigate directly to HomeScreen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage, style: GoogleFonts.montserrat())),
        );
      }
    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred.', style: GoogleFonts.montserrat())),
        );
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final primaryRedFromTheme = Theme.of(context).primaryColor;
    
    return Scaffold(
      body: AnimatedBuilder(
        animation: _gradientController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF8B0000), primaryRed, darkRed],
                begin: _topAlignmentAnimation.value,
                end: _bottomAlignmentAnimation.value,
              ),
            ),
            child: child,
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/White-Bright-Background-edit-online-2.jpeg',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.2),
              errorBuilder: (context, error, stackTrace) => Container(),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: Colors.white.withOpacity(0.95),
                  child: Container(
                    padding: const EdgeInsets.all(30.0),
                    decoration: BoxDecoration(
                      color: Colors.transparent, 
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryRed.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: ScaleTransition(
                              scale: _heartbeatScaleAnimation,
                              child: Text(
                                _isLogin ? 'Welcome Back' : 'Join the Lifeline',
                                style: GoogleFonts.bebasNeue(fontSize: 48, color: navyContrast),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Text(
                            _isLogin ? 'Sign In to continue saving lives.' : 'Create your account.',
                            style: GoogleFonts.montserrat(fontSize: 15, color: Colors.grey.shade600),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
                          if (!_isLogin) ...[
                            TextFormField(
                              controller: _nameController,
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: Icon(Icons.person, color: primaryRed),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: darkRed, width: 2)),
                              ),
                              validator: (val) => val == null || val.isEmpty ? 'Please enter your name' : null,
                            ),
                            const SizedBox(height: 16),
                          ],
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: Icon(Icons.email, color: primaryRed),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: darkRed, width: 2)),
                            ),
                            validator: (val) => val == null || !val.contains('@') ? 'Enter a valid email' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock, color: primaryRed),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: darkRed, width: 2)),
                            ),
                            validator: (val) => val!.length < 6 ? 'Password must be at least 6 characters' : null,
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _showForgotPasswordDialog,
                              child: Text('Forgot password?', style: GoogleFonts.montserrat(color: navyContrast)),
                            ),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _submitAuthForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkRed,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 5,
                            ),
                            child: _isLoading
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                                : Text(
                                    _isLogin ? 'SIGN IN' : 'REGISTER',
                                    style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w800),
                                  ),
                          ),
                          const SizedBox(height: 30),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                                _emailController.clear();
                                _passwordController.clear();
                                _nameController.clear();
                              });
                            },
                            child: Text(
                              _isLogin ? 'Need an account? Register Here' : 'Already have an account? Sign In',
                              style: GoogleFonts.montserrat(color: darkRed, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
