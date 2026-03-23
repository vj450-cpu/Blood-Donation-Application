// lib/screens/donors_screen.dart

import 'package:blood_donation_full/models/donor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/app_state.dart';
import '../widgets/donor_card.dart';
import 'donor_registration.dart'; // Updated: We use self-registration screen

class DonorsScreen extends StatefulWidget {
  const DonorsScreen({super.key});

  @override
  State<DonorsScreen> createState() => _DonorsScreenState();
}

class _DonorsScreenState extends State<DonorsScreen> {
  final Color primaryRed = const Color(0xFFD32F2F);
  final Color darkRed = const Color(0xFFC62828);
  final Color lightRedAccent = const Color(0xFFFFCDD2);

  final TextEditingController _searchController = TextEditingController();
  Future<List<Donor>>? _donorsFuture;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _donorsFuture = null;
      });
    } else {
      _performSearch(_searchController.text);
    }
  }

  void _performSearch(String query) {
    final appState = Provider.of<AppState>(context, listen: false);
    setState(() {
      _donorsFuture = appState.searchDonors(city: query);
    });
  }

  Future<void> _refreshDonors() async {
    if (_searchController.text.isNotEmpty) {
      _performSearch(_searchController.text);
    } else {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Widget _buildDonorList(List<Donor> donors) {
    return donors.isEmpty
        ? _buildEmptyState()
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: donors.length,
            itemBuilder: (context, index) {
              final donor = donors[index];
              return DonorCard(donor: donor);
            },
          );
  }

  // 🔹 UPDATED EMPTY STATE
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No registered donors match your search.\nYou can register yourself as a donor!',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DonorRegistration()),
              );
            },
            icon: const Icon(Icons.volunteer_activism, color: Colors.white),
            label: Text(
              'Register as Donor',
              style: GoogleFonts.montserrat(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: darkRed,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    final dataWidget = _donorsFuture != null
        ? FutureBuilder<List<Donor>>(
            future: _donorsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(primaryRed)));
              }
              if (snapshot.hasError) {
                return Center(
                    child: Text('Error loading data: ${snapshot.error}'));
              }
              return _buildDonorList(snapshot.data ?? []);
            },
          )
        : StreamBuilder<List<Donor>>(
            stream: appState.donorsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(primaryRed)));
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              return _buildDonorList(snapshot.data ?? []);
            },
          );

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
          'Available Donors',
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

      // 🔹 UPDATED FLOATING ACTION BUTTON
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DonorRegistration()),
          );
        },
        label: Text(
          'Register as Donor',
          style: GoogleFonts.montserrat(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        icon: const Icon(Icons.volunteer_activism, color: Colors.white),
        backgroundColor: darkRed,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),

      body: RefreshIndicator(
        onRefresh: _refreshDonors,
        color: primaryRed,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by city, name, or blood group',
                        hintStyle:
                            GoogleFonts.montserrat(color: Colors.grey.shade600),
                        prefixIcon: Icon(Icons.search, color: primaryRed),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 20.0),
                      ),
                      style: GoogleFonts.montserrat(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: Icon(Icons.filter_list, color: primaryRed),
                    label: Text(
                      'Filter',
                      style: GoogleFonts.montserrat(
                          color: primaryRed, fontWeight: FontWeight.w600),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Filter options coming soon!')),
                      );
                    },
                    backgroundColor: lightRedAccent.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: primaryRed.withOpacity(0.5)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: dataWidget),
          ],
        ),
      ),
    );
  }
}
