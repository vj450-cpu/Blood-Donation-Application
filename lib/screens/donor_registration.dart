import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart'; // Added for consistent styling

class DonorRegistration extends StatefulWidget {
  const DonorRegistration({Key? key}) : super(key: key);

  @override
  _DonorRegistrationState createState() => _DonorRegistrationState();
}

class _DonorRegistrationState extends State<DonorRegistration> with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bloodTypeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  final Color primaryRed = const Color(0xFFD32F2F); // Defined colors for use
  final Color darkRed = const Color(0xFFC62828);
  final Color lightGray = const Color(0xFFF5F5F5);

  bool _isLoading = false;

  // 🎯 NEW: Animation Controllers for background
  late AnimationController _bgGradientController;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animated gradient (Same logic as other screens)
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

    final user = FirebaseAuth.instance.currentUser;

    // Prefill user data if available
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';
      _phoneController.text = user.phoneNumber ?? '';
    }
  }

  Future<void> _registerDonor() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to register.")),
      );
      return;
    }

    // Basic validation check
    if (_bloodTypeController.text.isEmpty || _cityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill Blood Type and City.")),
      );
      return;
    }

    // Optional: Add validation for blood type format (e.g., A+, O-, etc.)

    setState(() {
      _isLoading = true;
    });

    // You should get Lat/Lng here if you intend to use the map feature properly.
    // For now, only basic fields are saved.
    
    try {
      await FirebaseFirestore.instance.collection('donors').doc(user.uid).set({
        'uid': user.uid,
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'bloodGroup': _bloodTypeController.text, // Renamed to bloodGroup for consistency
        'city': _cityController.text,
        'registeredAt': Timestamp.now(),
        // Add default Lat/Lng so app doesn't crash on map view
        'lat': 0.0, 
        'lng': 0.0,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You have successfully registered as a donor!")),
      );

      // Re-fetch profile data on the ProfileScreen after pop
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bloodTypeController.dispose();
    _cityController.dispose();
    _bgGradientController.dispose(); // 🎯 NEW: Dispose animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register as Donor', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: darkRed,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      
      // 🎯 WRAP BODY IN ANIMATEDBUILDER FOR BACKGROUND
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Note: You can only register yourself as a donor using your logged-in account.",
                  style: GoogleFonts.montserrat(
                    color: darkRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                readOnly: true,
                style: GoogleFonts.montserrat(color: Colors.grey.shade700),
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: const Icon(Icons.person, color: Colors.grey),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                readOnly: true,
                style: GoogleFonts.montserrat(color: Colors.grey.shade700),
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email, color: Colors.grey),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                readOnly: true,
                style: GoogleFonts.montserrat(color: Colors.grey.shade700),
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone, color: Colors.grey),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _bloodTypeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Blood Type (e.g., A+, O-)*',
                  prefixIcon: Icon(Icons.bloodtype, color: primaryRed),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cityController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'City*',
                  prefixIcon: const Icon(Icons.location_city, color: Colors.blueGrey),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _registerDonor,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: darkRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Register as Donor",
                        style: GoogleFonts.montserrat(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}