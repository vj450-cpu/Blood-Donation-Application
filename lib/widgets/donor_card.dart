import 'package:blood_donation_full/models/donor.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class DonorCard extends StatelessWidget {
  final Donor donor;
  final Color primaryRed = const Color(0xFFD32F2F);
  final Color darkRed = const Color(0xFFC62828);

  const DonorCard({super.key, required this.donor});

  Future<void> _launchUrl(BuildContext context, Uri url, String action) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not $action ${donor.phone}', style: GoogleFonts.montserrat()),
          backgroundColor: darkRed,
        ),
      );
    }
  }

  void _showContactOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return Container(
          padding: const EdgeInsets.only(top: 16),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Contact ${donor.name}',
                    style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.call, color: Colors.green),
                  title: Text('Call Donor', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
                  subtitle: Text(donor.phone, style: GoogleFonts.montserrat()),
                  onTap: () {
                    Navigator.pop(bc);
                    final Uri callLaunchUri = Uri(scheme: 'tel', path: donor.phone);
                    _launchUrl(context, callLaunchUri, 'call');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.message, color: Colors.blue),
                  title: Text('Send Message (SMS)', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
                  subtitle: Text('Open SMS app to text', style: GoogleFonts.montserrat()),
                  onTap: () {
                    Navigator.pop(bc);
                    final Uri smsLaunchUri = Uri(scheme: 'sms', path: donor.phone);
                    _launchUrl(context, smsLaunchUri, 'message');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.cancel, color: darkRed),
                  title: Text('Cancel', style: GoogleFonts.montserrat()),
                  onTap: () => Navigator.pop(bc),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(colors: [Colors.white, Colors.grey.shade50], begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.12), blurRadius: 10, offset: const Offset(0, 6))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              // Decorative faint image positioned to the right (use professional imagery)
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Opacity(
                    opacity: 0.06,
                    child: Image.asset('assets/images/download.jpeg', width: 120, height: 120, fit: BoxFit.cover),
                  ),
                ),
              ),

              Row(
                children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey.shade200,
                child: Text(
                  donor.avatarText, // computed getter from Donor
                  style: GoogleFonts.montserrat(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      donor.name,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${donor.bloodGroup} • ${donor.city}',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.message, color: Colors.blueAccent),
                tooltip: 'Send Message',
                onPressed: () => _showContactOptions(context),
              ),
              IconButton(
                icon: Icon(Icons.call, color: primaryRed),
                tooltip: 'Call Donor',
                onPressed: () => _showContactOptions(context),
              ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
