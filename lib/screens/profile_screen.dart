import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    
    return ValueListenableBuilder<UserRole>(
      valueListenable: authService.roleNotifier,
      builder: (context, currentRole, _) {
        final isBuyer = currentRole == UserRole.buyer;

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: isBuyer ? const Color(0xFFE11D48) : Colors.black87,
                    child: const Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text("User Account", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(isBuyer ? "Buyer Account" : "Seller Account", style: const TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 40),

                  // Role Switcher
                  Card(
                    elevation: 4,
                    child: InkWell(
                      onTap: () => isBuyer ? authService.switchToSeller() : authService.switchToBuyer(),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Icon(isBuyer ? Icons.store : Icons.shopping_bag, color: isBuyer ? Colors.black : const Color(0xFFE11D48)),
                            const SizedBox(width: 16),
                            Expanded(child: Text(isBuyer ? "Switch to Seller Mode" : "Switch to Buyer Mode", style: const TextStyle(fontWeight: FontWeight.bold))),
                            const Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // My Orders (Visible for Buyers)
                  if (isBuyer)
                    ListTile(
                      leading: const Icon(Icons.shopping_bag_outlined),
                      title: const Text("My Orders"),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const BuyerOrdersScreen()));
                      },
                    ),
                  
                  const Spacer(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text("Log Out", style: TextStyle(color: Colors.red)),
                    onTap: () => authService.signOut(),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}

class BuyerOrdersScreen extends StatelessWidget {
  const BuyerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text("Please login")));

    return Scaffold(
      appBar: AppBar(title: const Text("My Orders")),
      body: StreamBuilder<List<OrderModel>>(
        stream: DatabaseService().getBuyerOrders(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("You haven't bought anything yet."));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final order = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Image.network(order.product.image, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Icon(Icons.shopping_bag)),
                  title: Text(order.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Status: ${order.status}\nDate: ${order.date.toString().split(' ')[0]}"),
                  trailing: Text("\$${order.product.price}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
