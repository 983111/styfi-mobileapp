import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';
import 'models.dart';
import 'screens/home_screen.dart'; // Buyer Screen
import 'screens/login_screen.dart';
import 'screens/seller_dashboard.dart'; // Seller Screen
import 'screens/role_selection_screen.dart'; // Selection Screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Supabase.initialize(
    url: 'https://fxfwxcipaxxhflpyifkd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ4Znd4Y2lwYXh4aGZscHlpZmtkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAwNDMzMzMsImV4cCI6MjA4NTYxOTMzM30.6fJ2BtVEoEs-v6AlYuFGMxUyfTYxYBTygj9VIiIsDBo',
  );
  
  AuthService().init(); // Start listening to role changes
  runApp(const StyfiApp());
}

class StyfiApp extends StatelessWidget {
  const StyfiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Styfi Amazon Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE11D48)),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Listen to Auth State (Logged In vs Out)
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, authSnapshot) {
        if (!authSnapshot.hasData) {
          return const LoginScreen();
        }

        // 2. Listen to Role State (Buyer vs Seller vs None)
        return ValueListenableBuilder<UserRole?>(
          valueListenable: AuthService().roleNotifier,
          builder: (context, role, _) {
            if (role == null) {
              // Logged in, but no role selected -> Show Selection Screen
              return const RoleSelectionScreen();
            } else if (role == UserRole.seller) {
              return const SellerDashboard();
            } else {
              return const MainScreen(); // Existing Buyer Screen
            }
          },
        );
      },
    );
  }
}
