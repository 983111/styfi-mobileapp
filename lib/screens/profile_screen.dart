import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Profile Picture
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFFE11D48),
                child: const Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 16),
              
              // Name / Title
              const Text(
                "My Profile",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                authService.currentUser?.email ?? "User",
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              
              const SizedBox(height: 40),
              
              // Simple Account Options
              ListTile(
                leading: const Icon(Icons.shopping_bag_outlined, color: Colors.black87),
                title: const Text("My Orders", style: TextStyle(fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  // Navigate to orders if implemented
                },
              ),
              
              const Divider(),

              ListTile(
                leading: const Icon(Icons.settings_outlined, color: Colors.black87),
                title: const Text("Settings", style: TextStyle(fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  // Navigate to settings
                },
              ),
              
              const Spacer(),
              
              // Log Out Button
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Log Out", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () => authService.signOut(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
