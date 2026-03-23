import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// Screens
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/drives_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/blood_request_screen.dart';
import 'screens/blood_requests_list_screen.dart'; 
// Providers
import 'providers/app_state.dart';
// Utils
import 'utils/fade_page_route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const BloodDonationApp(),
    ),
  );
}

class BloodDonationApp extends StatelessWidget {
  const BloodDonationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blood Donation',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        primaryColor: const Color(0xFFC62828),
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.varelaRoundTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFC62828),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFFD32F2F),
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const SplashScreen(), 
    );
  }
}

/// AuthDecider: Checks if user is logged in
class AuthDecider extends StatelessWidget {
  const AuthDecider({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryRed = Theme.of(context).primaryColor;
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryRed)),
            ),
          );
        }

        // FIX 1: Add a key to MainShell to force a full widget rebuild upon login
        if (snapshot.hasData && snapshot.data != null) {
          return const MainShell(key: ValueKey('MainShellLoggedIn'));
        }

        // FIX 2: Added key to AuthScreen for consistent lifecycle management
        return const AuthScreen(key: ValueKey('AuthScreenLoggedOut'));
      },
    );
  }
}

/// MainShell: Bottom Navigation App (The primary Scaffold)
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _idx = 0;
  
  // FIX 3: Remove 'const' from HomeScreen() 
  final pages = [
    HomeScreen(), 
    const BloodRequestsListScreen(), 
    const MapScreen(),
    const DrivesScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    // 🎯 FIX 4: Explicitly call super.initState() in the navigation shell 
    // to guarantee the state is fully initialized before the first frame.
    super.initState(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The IndexedStack must resolve its content for the Scaffold to draw the BottomBar correctly.
      body: IndexedStack(index: _idx, children: pages),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(builder: (_) => const BloodRequestScreen()));
        },
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        onTap: (v) => setState(() => _idx = v),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event_note), label: 'Requests'), 
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Drives'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}