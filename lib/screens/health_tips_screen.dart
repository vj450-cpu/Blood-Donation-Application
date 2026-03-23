import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 1. CONVERTED TO STATEFULWIDGET
class HealthTipsScreen extends StatefulWidget {
  const HealthTipsScreen({Key? key}) : super(key: key);

  @override
  State<HealthTipsScreen> createState() => _HealthTipsScreenState();
}

// 2. STATE CLASS WITH ANIMATION MIXIN AND LOGIC
class _HealthTipsScreenState extends State<HealthTipsScreen> with TickerProviderStateMixin {

  final Color primaryRed = const Color(0xFFD32F2F);
  final Color darkRed = const Color(0xFFC62828); // Added for consistency
  final Color lightRedAccent = const Color(0xFFFFCDD2);
  final Color navyContrast = const Color(0xFF2C3E50);
  final Color lightGray = const Color(0xFFF5F5F5); // Added for gradient base

  // 🎯 NEW: Animation Controllers
  late AnimationController _bgGradientController;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animated gradient
    _bgGradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    _topAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(tween: Tween(begin: Alignment.topRight, end: Alignment.topLeft), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Alignment.topLeft, end: Alignment.bottomLeft), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Alignment.bottomLeft, end: Alignment.bottomRight), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Alignment.bottomRight, end: Alignment.topRight), weight: 1),
    ]).animate(_bgGradientController);

    _bottomAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(tween: Tween(begin: Alignment.bottomLeft, end: Alignment.bottomRight), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Alignment.bottomRight, end: Alignment.topRight), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Alignment.topRight, end: Alignment.topLeft), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Alignment.topLeft, end: Alignment.bottomLeft), weight: 1),
    ]).animate(_bgGradientController);
  }

  @override
  void dispose() {
    _bgGradientController.dispose();
    super.dispose();
  }

  Widget _buildSection(String title, List<String> tips) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.montserrat(
                  fontSize: 20, fontWeight: FontWeight.w800, color: navyContrast)),
          const SizedBox(height: 10),
          ...tips.map((tip) => Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  color: lightRedAccent.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle, color: primaryRed, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            tip,
                            style: GoogleFonts.montserrat(fontSize: 14, color: navyContrast),
                          ),
                        ),
                      ],
                    ),
                  ),
                ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final preDonationTips = [
      "Ensure you are well-hydrated before donation.",
      "Have a healthy meal 2–3 hours before donating.",
      "Avoid alcohol and fatty foods before donation.",
      "Bring your ID and donor card (if any).",
    ];

    final postDonationTips = [
      "Sit and rest for 5–10 minutes after donation.",
      "Drink plenty of fluids and have a light snack.",
      "Avoid heavy exercise for the rest of the day.",
      "Keep the bandage on for at least 4–6 hours.",
    ];

    final bloodTypeInfo = [
      "A+: Can donate to A+ and AB+, receive from A+ and A-, O+ and O-.",
      "B+: Can donate to B+ and AB+, receive from B+ and B-, O+ and O-.",
      "AB+: Universal recipient; can donate to AB+ only.",
      "O+: Can donate to A+, B+, AB+, O+, receive from O+ and O-.",
      "A-, B-, AB-, O-: Can donate to all positive & negative as per compatibility; O- is universal donor.",
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Health Tips & Blood Info", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        backgroundColor: primaryRed,
        centerTitle: true,
      ),
      
      // 3. WRAP BODY IN ANIMATEDBUILDER FOR BACKGROUND
      body: AnimatedBuilder(
        animation: _bgGradientController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  lightGray,
                  primaryRed.withOpacity(0.08),
                  darkRed.withOpacity(0.08)
                ],
                begin: _topAlignmentAnimation.value,
                end: _bottomAlignmentAnimation.value,
              ),
            ),
            // The SingleChildScrollView content is the child
            child: child, 
          );
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection("Pre-Donation Tips", preDonationTips),
              _buildSection("Post-Donation Care", postDonationTips),
              _buildSection("Blood Types & Compatibility", bloodTypeInfo),
              const SizedBox(height: 30),
              Center(
                child: Text("Your donation saves lives! 🩸",
                    style: GoogleFonts.montserrat(
                        fontSize: 16, fontWeight: FontWeight.w700, color: primaryRed)),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}