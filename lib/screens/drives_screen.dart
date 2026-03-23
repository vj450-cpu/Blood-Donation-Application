import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state.dart';
import '../models/drive.dart';
import 'add_drive_screen.dart';

// 1. CONVERTED TO STATEFULWIDGET
class DrivesScreen extends StatefulWidget {
  const DrivesScreen({super.key});

  @override
  State<DrivesScreen> createState() => _DrivesScreenState();
}

// 2. STATE CLASS WITH ANIMATION MIXIN AND LOGIC
class _DrivesScreenState extends State<DrivesScreen> with TickerProviderStateMixin {
  final Color primaryRed = const Color(0xFFD32F2F);
  final Color darkRed = const Color(0xFFC62828);
  final Color lightAccent = const Color(0xFFFFCDD2); // Light red/pink accent
  final Color navyContrast = const Color(0xFF2C3E50); // Deep contrast for text
  final Color lightGray = const Color(0xFFF5F5F5); // For gradient base

  // Animation Controllers (Added)
  late AnimationController _bgGradientController;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize the same animated gradient as the Requests screen
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

  // Simple date formatter (moved inside State class)
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Show confirmation dialog on register/join
  void _showConfirmationDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('🎉 Registered!', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: darkRed)),
        content: Text('You are successfully registered for the "$title" drive. Thank you for being a hero!', style: GoogleFonts.montserrat()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.montserrat(color: darkRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Widget to display a single drive item
  Widget _buildDriveItem(BuildContext context, Drive d, bool isHorizontal) {
    
    // Content for both horizontal and vertical cards
    final driveContent = Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(d.title, style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 16, color: navyContrast)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, size: 14, color: primaryRed),
              const SizedBox(width: 4),
              Text(d.city, style: GoogleFonts.montserrat(color: Colors.grey.shade700, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Date: ${_formatDate(d.date)}', style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: primaryRed)),
          const SizedBox(height: 12),
          // Animated Join button
          _AnimatedJoinButton(
            label: 'Join Drive',
            onConfirmed: () => _showConfirmationDialog(context, d.title),
            color: darkRed,
          ),
        ],
      ),
    );

    // Horizontal Card Layout (Featured Section) - Richer UI
    if (isHorizontal) {
      return Container(
        width: 300, 
        margin: const EdgeInsets.only(right: 16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          clipBehavior: Clip.antiAlias,
          elevation: 6, // Increased elevation for depth
          shadowColor: primaryRed.withOpacity(0.4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Area with gradient overlay
              Expanded(
                flex: 2,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      d.image.isNotEmpty ? d.image : 'assets/images/drive1.png', 
                      fit: BoxFit.cover, 
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: lightAccent, 
                          child: Center(child: Icon(Icons.event_available, size: 50, color: darkRed)),
                        );
                      },
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.4)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 12,
                      child: Text('Register Now!', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    )
                  ],
                ),
              ),
              // Content Area
              Expanded(flex: 3, child: driveContent),
            ],
          ),
        ),
      );
    }

    // Vertical ListTile Layout (Full List) - Richer UI
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3, // Minimal elevation
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            // Gradient leading element
            gradient: LinearGradient(
              colors: [primaryRed, darkRed],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [BoxShadow(color: darkRed.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))]
          ),
          child: Center(
            child: Text(
              d.date.day.toString(),
              style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
            ),
          ),
        ),
        title: Text(d.title, style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: navyContrast)),
        subtitle: Text('${d.city} | ${_formatDate(d.date)}', style: GoogleFonts.montserrat(color: Colors.grey.shade700)),
        trailing: ElevatedButton(
          onPressed: () => _showConfirmationDialog(context, d.title),
          style: ElevatedButton.styleFrom(
            backgroundColor: lightAccent.withOpacity(0.7),
            foregroundColor: darkRed, 
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: const Text('JOIN'),
        ),
      ),
    );
  }

  // Main Widget Builder
  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddDriveScreen()),
          );
        },
        backgroundColor: darkRed,
        foregroundColor: Colors.white,
        elevation: 8,
        child: const Icon(Icons.add),
      ),
      
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryRed, darkRed],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)]
          ),
        ),
        title: Text(
          '🩸 Donation Drives',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      
      // 3. WRAP BODY IN ANIMATEDBUILDER FOR BACKGROUND
      body: AnimatedBuilder(
        animation: _bgGradientController,
        builder: (context, child) {
          return Container(
            // Apply the animated gradient here
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
            // The StreamBuilder content goes inside
            child: child,
          );
        },
        child: StreamBuilder<List<Drive>>(
          stream: app.drivesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryRed)));
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error loading drives: ${snapshot.error}', textAlign: TextAlign.center, style: GoogleFonts.montserrat(color: darkRed)));
            }

            final drives = snapshot.data ?? [];

            if (drives.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, size: 60, color: lightAccent),
                      const SizedBox(height: 16),
                      Text(
                        'No upcoming drives scheduled right now.\n\nTap the "+" button to create a new campaign.',
                        style: GoogleFonts.montserrat(fontSize: 16, color: navyContrast),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.only(top: 24, bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Featured Drives Section (Horizontal List)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Featured Campaigns', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w900, color: navyContrast)),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300, // Increased height for better visual impact
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: drives.length,
                      itemBuilder: (context, idx) {
                        final d = drives[idx];
                        return _buildDriveItem(context, d, true);
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 2. All Upcoming Drives Section (Vertical List)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('All Upcoming Events', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w900, color: navyContrast)),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: List.generate(drives.length, (i) {
                        final d = drives[i];
                        return _buildDriveItem(context, d, false);
                      }),
                    ),
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


// Small animated join button used by drive cards (Re-added for complete context)
class _AnimatedJoinButton extends StatefulWidget {
  final String label;
  final VoidCallback onConfirmed;
  final Color color;

  const _AnimatedJoinButton({required this.label, required this.onConfirmed, required this.color});

  @override
  State<_AnimatedJoinButton> createState() => _AnimatedJoinButtonState();
}

class _AnimatedJoinButtonState extends State<_AnimatedJoinButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    try {
      setState(() => _loading = true);
      await _ctrl.forward();
      await Future.delayed(const Duration(milliseconds: 300));
      widget.onConfirmed();
    } finally {
      _ctrl.reverse();
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _loading ? null : _onTap,
      child: ScaleTransition(
        scale: Tween(begin: 1.0, end: 0.96).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            // Richer button styling with gradient and shadow
            gradient: LinearGradient(colors: [widget.color, widget.color.withOpacity(0.9)]),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: widget.color.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 3))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_loading) ...[
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                const SizedBox(width: 8),
              ],
              Text(widget.label, style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}