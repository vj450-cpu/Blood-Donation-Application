import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import '../providers/app_state.dart';
import '../models/blood_request.dart';

class BloodRequestScreen extends StatefulWidget {
  const BloodRequestScreen({super.key});

  @override
  State<BloodRequestScreen> createState() => _BloodRequestScreenState();
}

class _BloodRequestScreenState extends State<BloodRequestScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _unitsController = TextEditingController();
  final _noteController = TextEditingController();
  final _phoneController = TextEditingController();

  String _bloodGroup = 'O+';
  String _selectedCity = 'Mumbai';
  
  bool _isSubmitting = false;

  final Color primaryRed = const Color(0xFFD32F2F);
  final Color darkRed = const Color(0xFFC62828);
  final Color navyContrast = const Color(0xFF2C3E50);
  final Color lightGray = const Color(0xFFF5F5F5); // Added for gradient base

  // 🎯 NEW: Animation Controllers for background
  late AnimationController _bgGradientController;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  final Map<String, LatLng> cityCoords = {
    'Mumbai': const LatLng(19.0760, 72.8777),
    'Delhi': const LatLng(28.7041, 77.1025),
    'Bengaluru': const LatLng(12.9716, 77.5946),
    'Chennai': const LatLng(13.0827, 80.2707),
    'Kolkata': const LatLng(22.5726, 88.3639),
    'Hyderabad': const LatLng(17.3850, 78.4867),
    'Pune': const LatLng(18.5204, 73.8567),
    'Ahmedabad': const LatLng(23.0225, 72.5714),
    'Jaipur': const LatLng(26.9124, 75.7873),
    'Lucknow': const LatLng(26.8467, 80.9462),
    'Varanasi': const LatLng(25.3176, 82.9739),
    'Ranchi': const LatLng(23.3441, 85.3096),
  };

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
  }
  
  @override
  void dispose() {
    _patientNameController.dispose();
    _unitsController.dispose();
    _noteController.dispose();
    _phoneController.dispose();
    _bgGradientController.dispose(); // 🎯 NEW: Dispose animation controller
    super.dispose();
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      style: GoogleFonts.montserrat(color: navyContrast),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryRed),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkRed, width: 2),
        ),
        fillColor: primaryRed.withOpacity(0.05),
        filled: true,
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownFormField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map(
            (g) => DropdownMenuItem(
              value: g,
              child: Text(g, style: GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
            ),
          )
          .toList(),
      onChanged: onChanged,
      style: GoogleFonts.montserrat(color: darkRed),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.montserrat(color: darkRed),
        prefixIcon: Icon(icon, color: primaryRed),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryRed.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkRed, width: 2),
        ),
        fillColor: primaryRed.withOpacity(0.05),
        filled: true,
      ),
      validator: validator,
    );
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final LatLng coords = cityCoords[_selectedCity]!;

      final newRequest = BloodRequest(
        id: const Uuid().v4(),
        patientName: _patientNameController.text.trim(),
        bloodGroup: _bloodGroup,
        units: int.parse(_unitsController.text.trim()),
        city: _selectedCity,
        note: _noteController.text.trim(),
        phone: _phoneController.text.trim(), // ✅ matches model
        lat: coords.latitude,
        lng: coords.longitude,
        timestamp: DateTime.now(),
      );

      await Provider.of<AppState>(context, listen: false).addRequest(newRequest);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Urgent blood request posted!', style: GoogleFonts.montserrat()),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error posting request: $e', style: GoogleFonts.montserrat()),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Note: AppBar Gradient logic removed as it was decorative and inconsistent with other screens' app bars
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkRed,
        title: Text(
          '🩸 New Blood Request',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
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
            // The form content is the child
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildTextFormField(
                  controller: _patientNameController,
                  label: 'Patient / Hospital Contact',
                  icon: Icons.local_hospital,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _unitsController,
                  label: 'Units Needed',
                  icon: Icons.format_list_numbered,
                  inputType: TextInputType.number,
                  validator: (v) => v == null || int.tryParse(v) == null || int.parse(v) <= 0
                      ? 'Enter a valid number of units'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildDropdownFormField(
                  label: 'Required Blood Group',
                  icon: Icons.bloodtype,
                  value: _bloodGroup,
                  items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
                  onChanged: (v) => setState(() => _bloodGroup = v!),
                ),
                const SizedBox(height: 16),
                _buildDropdownFormField(
                  label: 'Select City',
                  icon: Icons.location_on,
                  value: _selectedCity,
                  items: cityCoords.keys.toList(),
                  onChanged: (v) => setState(() => _selectedCity = v!),
                  validator: (v) => v == null ? 'Please select a city' : null,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _phoneController,
                  label: 'Contact Number',
                  icon: Icons.phone,
                  inputType: TextInputType.phone,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _noteController,
                  label: 'Additional Notes',
                  icon: Icons.notes,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitRequest,
                  icon: _isSubmitting ? const SizedBox.shrink() : const Icon(Icons.send, color: Colors.white),
                  label: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                      : Text('POST URGENT REQUEST', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}