import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../services/database_service.dart';
import '../models.dart';
import 'profile_screen.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const SellerProductsScreen(), // Actual Products Screen
    const SellerOrdersScreen(),   // Actual Orders Screen
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
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

// --- PRODUCT UPLOAD & LIST SCREEN ---
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
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final products = snapshot.data!;
          if (products.isEmpty) return const Center(child: Text("No products yet"));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
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

// --- DIALOG TO PICK IMAGE AND UPLOAD ---
class AddProductDialog extends StatefulWidget {
  final String uid;
  const AddProductDialog({super.key, required this.uid});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _catCtrl = TextEditingController();
  File? _imageFile;
  bool _uploading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.isEmpty || _priceCtrl.text.isEmpty || _imageFile == null) return;
    
    setState(() => _uploading = true);
    try {
      // 1. UPLOAD IMAGE (Now uses Supabase via DatabaseService)
      final imageUrl = await DatabaseService().uploadProductImage(_imageFile!, widget.uid);
      
      // 2. SAVE DATA
      final newProduct = Product(
        id: '',
        name: _nameCtrl.text,
        price: double.tryParse(_priceCtrl.text) ?? 0.0,
        category: _catCtrl.text.isEmpty ? 'General' : _catCtrl.text,
        image: imageUrl,
        description: 'Seller Upload',
        sellerId: widget.uid,
      );
      await DatabaseService().addProduct(newProduct);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("List New Item"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150, width: double.infinity,
                color: Colors.grey[200],
                child: _imageFile != null 
                  ? Image.file(_imageFile!, fit: BoxFit.cover) 
                  : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 40), Text("Tap to upload")]),
              ),
            ),
            const SizedBox(height: 10),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: _priceCtrl, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
            TextField(controller: _catCtrl, decoration: const InputDecoration(labelText: "Category")),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(onPressed: _uploading ? null : _submit, child: _uploading ? const CircularProgressIndicator() : const Text("Upload")),
      ],
    );
  }
}

// --- PLACEHOLDER ORDERS SCREEN ---
class SellerOrdersScreen extends StatelessWidget {
  const SellerOrdersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Orders will appear here"));
  }
}
