// lib/screens/add_drive_screen.dart (ENHANCED UI)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../providers/app_state.dart';
import '../models/drive.dart';

class AddDriveScreen extends StatefulWidget {
  const AddDriveScreen({super.key});

  @override
  State<AddDriveScreen> createState() => _AddDriveScreenState();
}

class _AddDriveScreenState extends State<AddDriveScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _cityController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  final Color primaryRed = const Color(0xFFD32F2F);
  final Color darkRed = const Color(0xFFC62828);
  final Color navyContrast = const Color(0xFF2C3E50); 

  @override
  void dispose() {
    _titleController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  // Themed Date Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryRed, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: navyContrast, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: darkRed),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Themed Time Picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryRed,
              onPrimary: Colors.white,
              onSurface: navyContrast,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: darkRed),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final driveDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final newDrive = Drive(
        id: const Uuid().v4(),
        title: _titleController.text,
        city: _cityController.text,
        date: driveDateTime,
        image: '', 
      );

      final appState = Provider.of<AppState>(context, listen: false);
      try {
        await appState.addDrive(newDrive);
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ New drive scheduled!', style: GoogleFonts.montserrat())),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Failed to add drive: $e', style: GoogleFonts.montserrat())),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Solid dark red app bar
        title: Text('Schedule Blood Drive', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: darkRed,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Field (Enhanced border style)
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Drive Title/Location Name',
                  prefixIcon: Icon(Icons.drive_eta, color: primaryRed),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: darkRed, width: 2),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 20),

              // City Field
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'City/Area',
                  prefixIcon: Icon(Icons.location_city, color: primaryRed),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: darkRed, width: 2),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a city' : null,
              ),
              const SizedBox(height: 20),
              
              // Date Picker
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: Icon(Icons.calendar_today, color: darkRed),
                  title: Text('Date: ${MaterialLocalizations.of(context).formatShortDate(_selectedDate)}', style: GoogleFonts.montserrat(fontSize: 16, color: navyContrast)),
                  trailing: const Icon(Icons.edit, color: Colors.grey),
                  onTap: () => _selectDate(context),
                ),
              ),
              const SizedBox(height: 10),

              // Time Picker
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: Icon(Icons.access_time, color: darkRed),
                  title: Text('Time: ${_selectedTime.format(context)}', style: GoogleFonts.montserrat(fontSize: 16, color: navyContrast)),
                  trailing: const Icon(Icons.edit, color: Colors.grey),
                  onTap: () => _selectTime(context),
                ),
              ),
              
              const SizedBox(height: 40),

              // Submit Button (Themed)
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : Text('Schedule Drive', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}