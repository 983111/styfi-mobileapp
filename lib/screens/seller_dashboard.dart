import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../services/database_service.dart';
import '../models.dart';
import 'profile_screen.dart';
// Import the features moved from User Panel
import 'virtual_try_on_screen.dart';
import 'image_enhancer_screen.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  int _currentIndex = 0;
  
  // Added Virtual Try-On and Image Enhancer to Seller screens
  final List<Widget> _screens = [
    const SellerProductsScreen(), 
    const SellerOrdersScreen(),
    const VirtualTryOnScreen(),
    const ImageEnhancerScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seller Central', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Products'),
          NavigationDestination(icon: Icon(Icons.local_shipping_outlined), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.camera_alt_outlined), label: 'Try-On'),
          NavigationDestination(icon: Icon(Icons.camera_enhance_outlined), label: 'Studio'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

// --- PRODUCTS TAB ---
class SellerProductsScreen extends StatefulWidget {
  const SellerProductsScreen({super.key});
  @override
  State<SellerProductsScreen> createState() => _SellerProductsScreenState();
}

class _SellerProductsScreenState extends State<SellerProductsScreen> {
  void _showAddProductDialog(String uid) {
    showDialog(context: context, builder: (context) => AddProductDialog(uid: uid));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductDialog(user.uid),
        label: const Text("Add Product"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Product>>(
        stream: DatabaseService().getSellerProducts(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("No products yet"));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final p = snapshot.data![index];
              return Card(
                child: ListTile(
                  leading: Image.network(p.image, width: 50, height: 50, fit: BoxFit.cover, 
                    errorBuilder: (c,e,s) => const Icon(Icons.image_not_supported)),
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("\$${p.price}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => DatabaseService().deleteProduct(p.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// --- ORDERS TAB ---
class SellerOrdersScreen extends StatelessWidget {
  const SellerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text("Please login"));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: StreamBuilder<List<OrderModel>>(
        stream: DatabaseService().getSellerOrders(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No orders received yet"));
          }

          final orders = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Order Date: ${order.date.toString().split(' ')[0]}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          Chip(
                            label: Text(order.status, style: const TextStyle(color: Colors.white, fontSize: 10)),
                            backgroundColor: order.status == 'Delivered' ? Colors.green : Colors.orange,
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Image.network(order.product.image, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Icon(Icons.error)),
                        title: Text(order.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("\$${order.product.price} • Qty: 1"),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Shipping To:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text("${order.address.fullName}", style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text("${order.address.street}, ${order.address.city}", style: const TextStyle(fontSize: 13)),
                            Text("Phone: ${order.address.phone}", style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text("Update Status: "),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: ['Processing', 'Shipped', 'Delivered', 'Cancelled'].contains(order.status) ? order.status : 'Processing',
                            onChanged: (val) {
                              if(val != null) DatabaseService().updateOrderStatus(order.id, val);
                            },
                            items: ['Processing', 'Shipped', 'Delivered', 'Cancelled'].map((e)=>DropdownMenuItem(value: e, child: Text(e))).toList(),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// --- ADD PRODUCT DIALOG ---
class AddProductDialog extends StatefulWidget {
  final String uid;
  const AddProductDialog({super.key, required this.uid});
  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _name = TextEditingController(); final _price = TextEditingController(); final _cat = TextEditingController();
  File? _file; bool _loading = false;

  Future<void> _submit() async {
    if (_name.text.isEmpty || _price.text.isEmpty || _file == null) return;
    setState(() => _loading = true);
    try {
      final url = await DatabaseService().uploadProductImage(_file!, widget.uid);
      final prod = Product(id: '', name: _name.text, price: double.parse(_price.text), category: _cat.text, image: url, description: 'Seller Item', sellerId: widget.uid);
      await DatabaseService().addProduct(prod);
      if(mounted) Navigator.pop(context);
    } catch(e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if(mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("New Product"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () async { final x = await ImagePicker().pickImage(source: ImageSource.gallery); if(x!=null) setState(()=>_file=File(x.path)); },
            child: Container(height: 100, color: Colors.grey[200], child: _file != null ? Image.file(_file!) : const Icon(Icons.add_a_photo)),
          ),
          TextField(controller: _name, decoration: const InputDecoration(labelText: "Name")),
          TextField(controller: _price, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
        ],
      ),
      actions: [
        if(_loading) const CircularProgressIndicator() else ElevatedButton(onPressed: _submit, child: const Text("Upload"))
      ],
    );
  }
}
