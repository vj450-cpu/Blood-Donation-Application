import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 1. CONVERTED TO STATEFULWIDGET
class CompatibilityScreen extends StatefulWidget {
  const CompatibilityScreen({super.key});

  @override
  State<CompatibilityScreen> createState() => _CompatibilityScreenState();
}

// 2. STATE CLASS WITH ANIMATION MIXIN AND LOGIC
class _CompatibilityScreenState extends State<CompatibilityScreen> with TickerProviderStateMixin {
  
  final Color primaryRed = const Color(0xFFD32F2F);
  final Color darkRed = const Color(0xFFC62828);
  final Color navyContrast = const Color(0xFF2C3E50);
  final Color lightGray = const Color(0xFFF5F5F5); // Added for gradient base

  // 🎯 NEW: Animation Controllers
  late AnimationController _bgGradientController;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  // Data structure for the compatibility table (moved inside State class)
  final List<Map<String, dynamic>> compatibilityData = const [
    {'group': 'O-', 'donate': 'All Groups', 'receive': 'O-'},
    {'group': 'O+', 'donate': 'O+, A+, B+, AB+', 'receive': 'O+, O-'},
    {'group': 'A-', 'donate': 'A-, A+, AB-, AB+', 'receive': 'A-, O-'},
    {'group': 'A+', 'donate': 'A+, AB+', 'receive': 'A+, A-, O+, O-'},
    {'group': 'B-', 'donate': 'B-, B+, AB-, AB+', 'receive': 'B-, O-'},
    {'group': 'B+', 'donate': 'B+, AB+', 'receive': 'B+, B-, O+, O-'},
    {'group': 'AB-', 'donate': 'AB-, AB+', 'receive': 'AB-, B-, A-, O-'},
    {'group': 'AB+', 'donate': 'AB+', 'receive': 'All Groups'},
  ];

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

  // Table Cell Helper Widgets
  Widget _buildHeaderCell(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(text, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
      ),
    );
  }

  Widget _buildDataCell(String text, FontWeight weight, Color color) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(text, style: GoogleFonts.montserrat(fontWeight: weight, color: color, fontSize: 13)),
      ),
    );
  }
  
  Widget _buildSummaryPoint(String type, String description, IconData icon, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.montserrat(fontSize: 15, color: navyContrast),
              children: <TextSpan>[
                TextSpan(text: type, style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: ' $description'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blood Compatibility Chart', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: darkRed,
        iconTheme: const IconThemeData(color: Colors.white),
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
              Text(
                'Understanding Your Blood Type',
                style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w900, color: navyContrast),
              ),
              const SizedBox(height: 16),
              Text(
                'This chart shows which blood types can safely donate to and receive blood from others. Knowing these rules is crucial for transfusions.',
                style: GoogleFonts.montserrat(fontSize: 15, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 24),
              
              // Compatibility Table
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Table(
                    defaultColumnWidth: const IntrinsicColumnWidth(),
                    border: TableBorder.all(color: primaryRed.withOpacity(0.3), width: 1),
                    children: [
                      // Header Row
                      TableRow(
                        decoration: BoxDecoration(color: primaryRed.withOpacity(0.1)),
                        children: [
                          _buildHeaderCell('Type', darkRed),
                          _buildHeaderCell('Donate To', Colors.green.shade800),
                          _buildHeaderCell('Receive From', Colors.blue.shade800),
                        ],
                      ),
                      // Data Rows
                      ...compatibilityData.map((data) {
                        return TableRow(
                          children: [
                            _buildDataCell(data['group'], FontWeight.w900, darkRed),
                            _buildDataCell(data['donate'], FontWeight.w500, Colors.black87),
                            _buildDataCell(data['receive'], FontWeight.w500, Colors.black87),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Universal Donors/Recipients Summary
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryPoint('O Negative (O-)', 'is the **Universal Donor** (can donate to anyone).', Icons.ac_unit, Colors.red),
                    const SizedBox(height: 12),
                    _buildSummaryPoint('AB Positive (AB+)', 'is the **Universal Recipient** (can receive blood from anyone).', Icons.star, Colors.blue),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}