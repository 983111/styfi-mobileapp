import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_screen.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  int _currentIndex = 0;

  // Placeholder screens for the Seller Panel
  final List<Widget> _screens = [
    const _SellerHomePlaceholder(),
    const Center(child: Text("Product Management")),
    const Center(child: Text("Order Management")),
    const ProfileScreen(), // Reusing the profile screen for the switch
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Seller Central',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black87, // Distinct dark theme for sellers
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        indicatorColor: Colors.grey.shade300,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Products'),
          NavigationDestination(icon: Icon(Icons.local_shipping_outlined), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class _SellerHomePlaceholder extends StatelessWidget {
  const _SellerHomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Overview", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard("Earnings", "\$1,250", Colors.green),
            const SizedBox(width: 16),
            _buildStatCard("Orders", "12", Colors.blue),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Center(child: Text("Sales Chart Placeholder")),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
