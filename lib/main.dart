import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
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
          seedColor: const Color(0xFFE11D48), // Rose-600
          primary: const Color(0xFFE11D48),
          secondary: const Color(0xFFFDA4AF), // Rose-300
          surface: const Color(0xFFFFF1F2), // Rose-50
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFFFF1F2), // Rose-50
      ),
      home: const MainScreen(),
    );
  }
}
