import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/app_state.dart';
import '../models/blood_request.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapController _mapController = MapController();
  String _selectedCity = 'Mumbai';
  final Color primaryRed = const Color(0xFFD32F2F);
  final Color darkRed = const Color(0xFFC62828);
  final Color navyContrast = const Color(0xFF2C3E50);

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final app = Provider.of<AppState>(context, listen: false);
      app.initializeMarkers();
      app.registerMarkerTapCallback(_showRequestInfo);
    });
  }

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

  void _showRequestInfo(BloodRequest req) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'URGENT: ${req.patientName}',
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: darkRed,
                ),
              ),
              const Divider(),
              _buildInfoRow('Blood Group', req.bloodGroup, darkRed),
              _buildInfoRow('Units Needed', '${req.units} units', primaryRed),
              _buildInfoRow('Location', req.city, navyContrast),
              _buildInfoRow('Contact Note', req.note, navyContrast),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _launchDialer(req.phone); // ✅ fixed
                },
                icon: const Icon(Icons.call, color: Colors.white),
                label: Text(
                  'CALL Requester (${req.phone})',
                  style: GoogleFonts.montserrat(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkRed,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.montserrat(fontWeight: FontWeight.w500, color: navyContrast)),
          Text(value, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);

    app.registerMarkerTapCallback(_showRequestInfo);

    final Gradient appBarGradient = LinearGradient(
      colors: [primaryRed, darkRed],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkRed,
        title: ShaderMask(
          shaderCallback: (bounds) => appBarGradient.createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: Text(
            '📍 Live Request Map',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: app.initializeMarkers,
            tooltip: 'Refresh Requests',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: _selectedCity,
              decoration: InputDecoration(
                labelText: 'Center Map on City',
                labelStyle: GoogleFonts.montserrat(color: navyContrast),
                border: const OutlineInputBorder(),
              ),
              items: cityCoords.keys
                  .map((city) => DropdownMenuItem(
                        value: city,
                        child: Text(city, style: GoogleFonts.montserrat()),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() => _selectedCity = v);
                  _mapController.move(cityCoords[v]!, 10.0);
                }
              },
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: cityCoords[_selectedCity]!,
                initialZoom: 5.0,
                interactionOptions: const InteractionOptions(),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.fullblood_donation',
                ),
                MarkerLayer(markers: app.markers),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mapController.move(cityCoords[_selectedCity]!, 10.0);
        },
        backgroundColor: darkRed,
        foregroundColor: Colors.white,
        child: const Icon(Icons.location_searching),
      ),
    );
  }
}
