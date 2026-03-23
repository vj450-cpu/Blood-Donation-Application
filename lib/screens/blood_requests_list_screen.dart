import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart'; 
import '../providers/app_state.dart';
import '../models/blood_request.dart';

class BloodRequestsListScreen extends StatefulWidget {
  const BloodRequestsListScreen({super.key});

  @override
  State<BloodRequestsListScreen> createState() =>
      _BloodRequestsListScreenState();
}

class _BloodRequestsListScreenState extends State<BloodRequestsListScreen>
    with TickerProviderStateMixin {
  final Color primaryRed = const Color(0xFFD32F2F);
  final Color darkRed = const Color(0xFFC62828);
  final Color navyContrast = const Color(0xFF2C3E50);
  final Color lightRedAccent = const Color(0xFFFFCDD2);
  final Color lightGray = const Color(0xFFF5F5F5);

  late AnimationController _bgGradientController;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  @override
  void initState() {
    super.initState();

    _bgGradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    _topAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
          tween: Tween(begin: Alignment.topRight, end: Alignment.topLeft),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Alignment.topLeft, end: Alignment.bottomLeft),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Alignment.bottomLeft, end: Alignment.bottomRight),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Alignment.bottomRight, end: Alignment.topRight),
          weight: 1),
    ]).animate(_bgGradientController);

    _bottomAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
          tween: Tween(begin: Alignment.bottomLeft, end: Alignment.bottomRight),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Alignment.bottomRight, end: Alignment.topRight),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Alignment.topRight, end: Alignment.topLeft),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Alignment.topLeft, end: Alignment.bottomLeft),
          weight: 1),
    ]).animate(_bgGradientController);
  }

  @override
  void dispose() {
    _bgGradientController.dispose();
    super.dispose();
  }

  // --- Launch Phone Dialer ---
  Future<void> _launchDialer(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch dialer for $phoneNumber')),
        );
      }
    }
  }

  void _showContactDialog(BuildContext context, BloodRequest req) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Contact Details',
          style: GoogleFonts.montserrat(
              color: navyContrast, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Patient: ${req.patientName}', style: GoogleFonts.montserrat()),
              Text('Blood Group: ${req.bloodGroup}',
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold, color: darkRed)),
              Text('Units Needed: ${req.units}', style: GoogleFonts.montserrat()),
              const Divider(),
              Text('Location: ${req.city}', style: GoogleFonts.montserrat()),
              Text('Note: ${req.note}', style: GoogleFonts.montserrat(fontStyle: FontStyle.italic)),
              const Divider(),
              Text('Contact Number:', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
              Text(req.phone, style: GoogleFonts.montserrat(color: darkRed)),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: GoogleFonts.montserrat(color: darkRed))),
        ],
      ),
    );
  }

  Widget _buildRequestItem(BuildContext context, BloodRequest req) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shadowColor: primaryRed.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          width: 60,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: lightRedAccent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: primaryRed, width: 1.5),
          ),
          child: Center(
            child: Text(
              req.bloodGroup,
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w900, color: darkRed, fontSize: 16),
            ),
          ),
        ),
        title: Text(
          '${req.patientName} (${req.units} units)',
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w800, color: navyContrast),
        ),
        subtitle: Text(
          'Urgent need in ${req.city}',
          style: GoogleFonts.montserrat(color: Colors.grey.shade700),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => _showContactDialog(context, req),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkRed,
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              child: const Text('CONNECT'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _launchDialer(req.phone),
              icon: const Icon(Icons.call, size: 18),
              label: const Text('CALL'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              // Changed child to label, removed redundant child text
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkRed,
        title: Text(
          '🚨 All Urgent Requests',
          style: GoogleFonts.montserrat(
              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // 🎯 FIX: StreamBuilder is now the root of the body.
      body: StreamBuilder<List<BloodRequest>>(
        stream: app.requestsStream,
        builder: (context, snapshot) {
          // 1. LOADING STATE (NOT inside the constantly animating widget)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(primaryRed)),
            );
          }

          // 2. ERROR STATE (will show if .handleError() in AppState is triggered)
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading requests: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(color: darkRed),
              ),
            );
          }

          // 3. DATA/EMPTY STATE (Now wrapped in AnimatedBuilder for the background)
          final requests = snapshot.data ?? [];

          return AnimatedBuilder(
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
                child: requests.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.warning_amber,
                                  size: 60, color: primaryRed.withOpacity(0.5)),
                              const SizedBox(height: 16),
                              Text(
                                'All clear! No urgent requests right now.',
                                style: GoogleFonts.montserrat(
                                    fontSize: 16, color: navyContrast),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: requests.length,
                        itemBuilder: (context, index) =>
                            _buildRequestItem(context, requests[index]),
                      ),
              );
            },
          );
        },
      ),
    );
  }
}