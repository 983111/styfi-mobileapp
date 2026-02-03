import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';
import 'screens/home_screen.dart';
import 'screens/seller_dashboard.dart'; // Ensure this file exists
import 'screens/login_screen.dart';
import 'models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(); 
  
  await Supabase.initialize(
    url: 'https://fxfwxcipaxxhflpyifkd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ4Znd4Y2lwYXh4aGZscHlpZmtkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAwNDMzMzMsImV4cCI6MjA4NTYxOTMzM30.6fJ2BtVEoEs-v6AlYuFGMxUyfTYxYBTygj9VIiIsDBo',
  );

  AuthService().init();
  
  runApp(const StyfiApp());
}

class StyfiApp extends StatelessWidget {
  const StyfiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Styfi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE11D48), 
          primary: const Color(0xFFE11D48),
          secondary: const Color(0xFFFDA4AF),
          surface: const Color(0xFFFFF1F2), 
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFFFF1F2),
      ),
      home: StreamBuilder(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const RoleManager();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}

class RoleManager extends StatelessWidget {
  const RoleManager({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserRole>(
      valueListenable: AuthService().roleNotifier,
      builder: (context, role, _) {
        if (role == UserRole.buyer) {
          return const MainScreen();
        } else {
          // FIX: Updated class name to SellerDashboardScreen
          return const SellerDashboardScreen();
        }
      },
    );
  }
}
