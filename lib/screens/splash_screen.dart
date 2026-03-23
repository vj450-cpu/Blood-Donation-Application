// lib/screens/splash_screen.dart

import 'package:blood_donation_full/main.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import '../screens/auth_screen.dart';
import '../utils/fade_page_route.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final Color primaryRed = const Color(0xFF8B0000);
  final Color darkRed = const Color(0xFF6A0000);
  final Color circleColor = const Color(0xFF4C0000);
  final Color lightRedAccent = const Color(0xFFFFCDD2);

  late AnimationController _dotController;
  final int totalDots = 200; // more dots
  final List<double> _randomOffsets = []; // for non-uniform blinking
  final Random _rand = Random();

  @override
  void initState() {
    super.initState();
    // Generate random offsets for each dot (0 to 1)
    for (int i = 0; i < totalDots; i++) {
      _randomOffsets.add(_rand.nextDouble());
    }

    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 5-second splash delay
    await Future.delayed(const Duration(seconds: 5));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        FadePageRoute(child: const AuthDecider()),
      );
    }
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedDotGrid() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: List.generate(totalDots, (index) {
            return AnimatedBuilder(
              animation: _dotController,
              builder: (context, child) {
                // Use sin wave with random phase for non-uniform blinking
                double value = sin((_dotController.value + _randomOffsets[index]) * 2 * pi);
                double opacity = 0.3 + 0.7 * ((value + 1) / 2); // normalize to 0-1
                return Opacity(
                  opacity: opacity.clamp(0.2, 1.0),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: (index % 3 == 0)
                          ? Colors.white.withOpacity(0.9)
                          : lightRedAccent.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryRed, darkRed],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildAnimatedDotGrid(),
            Card(
              elevation: 15,
              shape: const CircleBorder(),
              color: circleColor,
              child: Padding(
                padding: const EdgeInsets.all(60),
                child: Text(
                  'LIFE LINE',
                  style: GoogleFonts.kanit(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.5,
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
