// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/app_state.dart';
import 'compatibility_screen.dart';
import 'blood_requests_list_screen.dart';
import 'donor_registration.dart';
import 'health_tips_screen.dart';

// Models
import '../models/donor.dart';
import '../models/blood_request.dart';
import '../models/drive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final Color primaryRed = const Color(0xFFD32F2F);
  final Color darkRed = const Color(0xFFC62828);
  final Color navyContrast = const Color(0xFF2C3E50);
  final Color lightGray = const Color(0xFFF5F5F5);

  // Animation Controllers (Same as before)
  AnimationController? _cardAnimationController;
  late Animation<double> _cardAnimation;
  
  late AnimationController _bgGradientController;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  bool _assetsPrecached = false; 

  @override
  void initState() {
    super.initState();

    // 1. Card Animation
    _cardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_cardAnimationController!);

    // 2. Background Gradient Animation (Kept from Requests screen)
    _bgGradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    _topAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem<Alignment>(tween: Tween(begin: Alignment.topRight, end: Alignment.topLeft), weight: 1),
      TweenSequenceItem<Alignment>(tween: Tween(begin: Alignment.topLeft, end: Alignment.bottomLeft), weight: 1),
      TweenSequenceItem<Alignment>(tween: Tween(begin: Alignment.bottomLeft, end: Alignment.bottomRight), weight: 1),
      TweenSequenceItem<Alignment>(tween: Tween(begin: Alignment.bottomRight, end: Alignment.topRight), weight: 1),
    ]).animate(_bgGradientController);

    _bottomAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem<Alignment>(tween: Tween(begin: Alignment.bottomLeft, end: Alignment.bottomRight), weight: 1),
      TweenSequenceItem<Alignment>(tween: Tween(begin: Alignment.bottomRight, end: Alignment.topRight), weight: 1),
      TweenSequenceItem<Alignment>(tween: Tween(begin: Alignment.topRight, end: Alignment.topLeft), weight: 1),
      TweenSequenceItem<Alignment>(tween: Tween(begin: Alignment.topLeft, end: Alignment.bottomLeft), weight: 1),
    ]).animate(_bgGradientController);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_assetsPrecached) {
      _initializeAsyncAssets();
      _assetsPrecached = true;
    }
  }

  void _initializeAsyncAssets() {
    try {
      if (mounted) {
        precacheImage(const AssetImage('assets/images/handgame.jpg'), context);
        precacheImage(const AssetImage('assets/images/drive1.png'), context);
        // precacheImage(const AssetImage('assets/images/background.jpg'), context); // Removed static background image
        precacheImage(const AssetImage('assets/images/donor_reg.jpg'), context);
        precacheImage(const AssetImage('assets/images/health_tips.jpg'), context);
        precacheImage(const AssetImage('assets/images/compatibility.jpg'), context);
        precacheImage(const AssetImage('assets/images/requests.jpg'), context);
      }
    } catch (e) {
      debugPrint("Asset precache error: $e"); 
    }
  }

  @override
  void dispose() {
    _cardAnimationController?.dispose();
    _bgGradientController.dispose();
    super.dispose();
  }

  // --- Widget Builders (unchanged) ---

  Widget _impactStatBox(String label, String value, IconData icon, Color color) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
        ],
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.18), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(value, style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w600, color: navyContrast)),
        ],
      ),
    );
  }

  Widget _buildVerticalInteractiveCards() {

    final List<Map<String, dynamic>> cardsData = [
      {'title': 'Become a Donor', 'subtitle': 'Register and save a life.', 'image': 'assets/images/donor_reg.jpg', 'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DonorRegistration()))},
      {'title': 'Health Insights', 'subtitle': 'Tips for a healthy life.', 'image': 'assets/images/health_tips.jpg', 'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HealthTipsScreen()))},
      {'title': 'Blood Type Match', 'subtitle': 'Check compatibility.', 'image': 'assets/images/compatibility.jpg', 'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CompatibilityScreen()))},
      {'title': 'View Blood Needs', 'subtitle': 'Respond to urgent requests.', 'image': 'assets/images/requests.jpg', 'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BloodRequestsListScreen()))},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 12.0),
          child: Text(
            'Quick Actions',
            style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w900, color: navyContrast),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: List.generate(cardsData.length, (index) {
              final card = cardsData[index];
              return AnimatedBuilder(
                animation: _cardAnimation,
                builder: (context, child) {
                  final alignment = Alignment.lerp(Alignment.topLeft, Alignment.bottomRight, _cardAnimation.value)!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: InkWell(
                      onTap: card['onTap'],
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5))],
                          gradient: LinearGradient(
                            colors: [darkRed.withOpacity(0.8), primaryRed.withOpacity(0.8)],
                            begin: alignment,
                            end: Alignment(-alignment.x, -alignment.y),
                          ),
                          image: DecorationImage(
                            image: AssetImage(card['image']),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(card['title'], style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 4),
                              Text(card['subtitle'], style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white70)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildHomeContent(BuildContext context, List<Donor> donors, List<BloodRequest> requests, List<Drive> drives) {
    const double bottomClearance = 100.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Stack(
            children: [
              Container(
                height: 280,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [const Color(0xFFF06292), primaryRed, darkRed], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 15, offset: const Offset(0, 8))],
                ),
              ),
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                  child: Opacity(
                    opacity: 0.15,
                    child: Image.asset('assets/images/handgame.jpg', fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: Colors.transparent))),
                ),
              ),
              Container(
                height: 280,
                padding: const EdgeInsets.all(16),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('🩸 Blood Hub', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: IconButton(icon: Icon(Icons.notifications_active, color: darkRed), onPressed: () {}),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 700),
                          builder: (context, val, child) => Opacity(
                            opacity: val,
                            child: Transform.translate(offset: Offset(0, 15 * (1 - val)), child: child),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'You Are The Lifeline',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  shadows: [Shadow(color: Colors.black.withOpacity(0.5), offset: const Offset(2, 2), blurRadius: 4)],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('Find, Donate, Request. Be a hero today.', style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildVerticalInteractiveCards(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Our Global Impact', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w900, color: navyContrast)),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _impactStatBox('Total Donors', donors.length.toString(), Icons.people_alt, Colors.blue.shade700),
                _impactStatBox('Urgent Requests', requests.length.toString(), Icons.warning, primaryRed),
                _impactStatBox('Upcoming Drives', drives.length.toString(), Icons.event_available, Colors.green.shade700),
              ],
            ),
          ),
          const SizedBox(height: bottomClearance),
        ],
      ),
    );
  }

  // --- Main Build Method ---

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 🎯 FIX 1: Wrap the entire Material in AnimatedBuilder to apply the background
        return AnimatedBuilder(
          animation: _bgGradientController,
          builder: (context, child) {
            return Material(
              // Apply the Animated Gradient Background
              color: Colors.transparent, // Ensure Material doesn't hide gradient
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [lightGray, primaryRed.withOpacity(0.08), darkRed.withOpacity(0.08)],
                    begin: _topAlignmentAnimation.value,
                    end: _bottomAlignmentAnimation.value,
                  ),
                ),
                // The rest of the content (child) goes here
                child: child!,
              ),
            );
          },
          // 🎯 FIX 2: The inner content is passed as the child to prevent unnecessary rebuilds
          child: Consumer<AppState>(
            builder: (context, app, child) {
              return StreamBuilder<List<Donor>>(
                stream: app.donorsStream,
                builder: (context, donorSnapshot) {
                  return StreamBuilder<List<BloodRequest>>(
                    stream: app.requestsStream,
                    builder: (context, requestSnapshot) {
                      return StreamBuilder<List<Drive>>(
                        stream: app.drivesStream,
                        builder: (context, driveSnapshot) {
                          // Check all streams for data availability
                          if (!donorSnapshot.hasData || !requestSnapshot.hasData || !driveSnapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(primaryRed),
                              ),
                            );
                          }

                          // If all streams have data, build the content.
                          return _buildHomeContent(
                            context,
                            donorSnapshot.data!,
                            requestSnapshot.data!,
                            driveSnapshot.data!,
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}