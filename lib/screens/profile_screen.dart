import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import '../providers/app_state.dart';
import '../models/donor.dart';
import 'donor_registration.dart';
import 'auth_screen.dart'; // Import AuthScreen to navigate directly

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  XFile? _photo;
  final Color primaryRed = const Color(0xFFD32F2F);
  final Color darkRed = const Color(0xFFC62828);
  final Color lightGray = const Color(0xFFF5F5F5); // Added for gradient base

  late User? firebaseUser;
  Future<Donor?>? _myDonorProfileFuture;
  
  // 🎯 NEW: Animation Controllers for background
  late AnimationController _bgGradientController;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize background animation (Same logic as Requests screen)
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

    firebaseUser = FirebaseAuth.instance.currentUser; 
    _fetchMyDonorProfile();
  }

  @override
  void dispose() {
    _bgGradientController.dispose(); // 🎯 NEW: Dispose animation controller
    super.dispose();
  }


  // Fetches the Donor profile ONLY if a Firebase user is logged in
  void _fetchMyDonorProfile() {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() => _myDonorProfileFuture = Future.value(null));
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);
    setState(() {
      _myDonorProfileFuture = appState.fetchDonorById(currentUser.uid); 
    });
  }

  // Helper function to safely extract initials
  String _safeInitials(String name) {
      if (name.isEmpty) return '?';
      final parts = name.trim().split(' ');
      
      if (parts.length >= 2 && parts[1].isNotEmpty) {
          return (parts[0][0] + parts[1][0]).toUpperCase();
      } 
      else {
          return name[0].toUpperCase();
      }
  }

  Future pickImage() async {
    final p = ImagePicker();
    try {
      final x = await p.pickImage(source: ImageSource.gallery, maxWidth: 800);
      if (x != null) {
        setState(() => _photo = x);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e', style: GoogleFonts.montserrat())),
      );
    }
  }
  
  void _showQrDialog(BuildContext context, String data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Unique Donor ID QR', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 250,
          height: 250,
          child: Center(
            child: QrImageView(
              data: data,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
              eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: darkRed),
              dataModuleStyle: QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: primaryRed),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Close', style: GoogleFonts.montserrat(color: darkRed))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser; 
    
    final fallbackDisplayName = currentUser?.displayName ?? currentUser?.email?.split('@').first ?? 'User';
    final userEmail = currentUser?.email ?? 'Not logged in';

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryRed, darkRed],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'My Profile',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      
      // 🎯 NEW: AnimatedBuilder wraps the entire body content for the background
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
            // The FutureBuilder content is passed as the child
            child: child,
          );
        },
        child: FutureBuilder<Donor?>(
          future: _myDonorProfileFuture,
          builder: (context, snapshot) {
            if (currentUser == null) {
              return Center(child: Text("Not logged in.", style: GoogleFonts.montserrat()));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryRed)));
            }
            if (snapshot.hasError) {
                return Center(child: Text('Error loading profile: ${snapshot.error}', style: GoogleFonts.montserrat()));
            }

            final Donor? donorProfile = snapshot.data;
            final bool isRegisteredDonor = donorProfile != null;
            
            final finalDisplayName = isRegisteredDonor ? donorProfile.name : fallbackDisplayName;
            final avatarInitials = _safeInitials(finalDisplayName);


            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. APPLICATION PROFILE HEADER 
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryRed.withOpacity(0.1),
                            border: Border.all(color: primaryRed, width: 3),
                          ),
                          child: Center(
                              child: Text(avatarInitials,
                                  style: GoogleFonts.bebasNeue(fontSize: 48, color: darkRed))),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          finalDisplayName, 
                          style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userEmail, 
                          style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                  
                  // --- 2. DONOR PROFILE SECTION (Conditional) ---
                  if (isRegisteredDonor) ...[
                    Text(
                      'Donor Information',
                      style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: darkRed),
                    ),
                    const Divider(color: Colors.grey, height: 20),
                    
                    // Blood Group Card
                    Card(
                      elevation: 4,
                      child: ListTile(
                        leading: Icon(Icons.bloodtype, color: primaryRed, size: 30),
                        title: Text('Blood Group', style: GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
                        subtitle: Text(donorProfile!.bloodGroup, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Phone Number Card
                    Card(
                      elevation: 4,
                      child: ListTile(
                        leading: Icon(Icons.phone_android, color: Colors.blue.shade700, size: 30),
                        title: Text('Contact Number', style: GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
                        subtitle: Text(donorProfile.phone, style: GoogleFonts.montserrat()),
                        trailing: IconButton(
                          icon: Icon(Icons.edit, color: Colors.grey.shade500),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Edit feature coming soon!')),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // QR Code Card
                    Card(
                      elevation: 6,
                      child: ListTile(
                        leading: Icon(Icons.qr_code_scanner, color: darkRed, size: 36),
                        title: Text('Your Donor QR ID', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
                        subtitle: Text('Show this QR code at donation centers.', style: GoogleFonts.montserrat(fontSize: 12)),
                        trailing: ElevatedButton(
                          onPressed: () => _showQrDialog(context, donorProfile.id),
                          child: const Text('Show'),
                          style: ElevatedButton.styleFrom(backgroundColor: primaryRed, foregroundColor: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                  ] else ...[
                    // 3. UNREGISTERED DONOR PROMPT
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: primaryRed.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: primaryRed.withOpacity(0.5)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.sentiment_dissatisfied, size: 60, color: primaryRed),
                          const SizedBox(height: 16),
                          Text(
                            'You are not a registered donor yet.',
                            style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: darkRed),
                          ),
                          const SizedBox(height: 8),
                          Text('Complete the donor registration to activate your profile and appear on the map.', textAlign: TextAlign.center, style: GoogleFonts.montserrat()),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>DonorRegistration())),
                            icon: const Icon(Icons.app_registration, color: Colors.white),
                            label: Text('Register as Donor', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkRed,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],

                  // 4. LOGOUT BUTTON (Always visible)
                  TextButton.icon(
                    onPressed: () async {
                      // 1. Sign out the user
                      await FirebaseAuth.instance.signOut();
                      
                      // 2. CRITICAL FIX: Navigate to the AuthScreen and remove all history
                      if (mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const AuthScreen()),
                              (Route<dynamic> route) => false,
                          );
                      }
                    },
                    icon: Icon(Icons.logout, color: darkRed),
                    label: Text('Logout', style: GoogleFonts.montserrat(color: darkRed, fontWeight: FontWeight.bold)),
                  ),
                  
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}