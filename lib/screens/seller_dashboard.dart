import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../models.dart';

class SellerDashboard extends StatefulWidget {
  const SellerDashboard({super.key});

  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  int _index = 0;
  
  final List<Widget> _screens = [
    const SellerProductsTab(),
    const SellerOrdersTab(),
    const SellerProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seller Central"), automaticallyImplyLeading: false),
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.inventory), label: 'Inventory'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}

// --- TAB 1: PRODUCTS ---
class SellerProductsTab extends StatelessWidget {
  const SellerProductsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(context: context, builder: (_) => const AddProductDialog()),
        label: const Text("Add Item"),
        icon: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Product>>(
        stream: DatabaseService().getSellerProducts(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.isEmpty) return const Center(child: Text("No items listed yet."));
          
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final p = snapshot.data![index];
              return ListTile(
                leading: Image.network(p.image, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.error)),
                title: Text(p.name),
                subtitle: Text("\$${p.price.toStringAsFixed(2)}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => DatabaseService().deleteProduct(p.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// --- TAB 2: ORDERS ---
class SellerOrdersTab extends StatelessWidget {
  const SellerOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder<List<OrderModel>>(
      stream: DatabaseService().getSellerOrders(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.isEmpty) return const Center(child: Text("No orders received yet."));

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final o = snapshot.data![index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                // FIX: Access name via o.product.name
                title: Text("Sold: ${o.product.name}"),
                // FIX: Access price via o.product.price
                subtitle: Text("Status: ${o.status}\nDate: ${o.date.toString().split(' ')[0]}"),
                trailing: Text(
                  "\$${o.product.price.toStringAsFixed(2)}", 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// --- TAB 3: PROFILE ---
class SellerProfileTab extends StatelessWidget {
  const SellerProfileTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => AuthService().signOut(),
        icon: const Icon(Icons.logout),
        label: const Text("Log Out"),
        style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
      ),
    );
  }
}

// --- ADD PRODUCT DIALOG ---
class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});
  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  File? _image;
  bool _loading = false;

  Future<void> _upload() async {
    if (_name.text.isEmpty || _price.text.isEmpty || _image == null) return;
    setState(() => _loading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      // Using the folder 'products' for organization
      final url = await DatabaseService().uploadImage(_image!, 'products');
      
      final product = Product(
        id: '', 
        name: _name.text, 
        price: double.parse(_price.text), 
        category: 'General', 
        image: url, 
        description: 'Seller Listing', 
        sellerId: uid
      );
      
      await DatabaseService().addProduct(product);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("New Listing"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () async {
              final x = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (x != null) setState(() => _image = File(x.path));
            },
            child: Container(
              height: 100, width: 100, color: Colors.grey[200],
              child: _image != null ? Image.file(_image!, fit: BoxFit.cover) : const Icon(Icons.add_a_photo),
            ),
          ),
          TextField(controller: _name, decoration: const InputDecoration(labelText: "Product Name")),
          TextField(controller: _price, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
        ],
      ),
      actions: [
        if (_loading) const CircularProgressIndicator() else ElevatedButton(onPressed: _upload, child: const Text("List It"))
      ],
    );
  }
}
