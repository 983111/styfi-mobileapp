import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import '../models.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client; // Supabase Client

  // --- Products ---
  Stream<List<Product>> getProducts() {
    return _db.collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Stream<List<Product>> getSellerProducts(String sellerId) {
    return _db.collection('products')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // --- Image Upload Function (Switched to Supabase) ---
  Future<String> uploadProductImage(File imageFile, String uid) async {
    try {
      // 1. Generate unique path: products/{uid}/{timestamp}.jpg
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String path = '$uid/$fileName';

      // 2. Upload to Supabase Storage (Bucket name: 'products')
      // Make sure you create a bucket named 'products' in your Supabase dashboard and make it Public.
      await _supabase.storage.from('products').upload(
        path,
        imageFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      // 3. Get Public URL
      final String imageUrl = _supabase.storage.from('products').getPublicUrl(path);
      
      return imageUrl;
    } catch (e) {
      print("Upload Error: $e");
      throw Exception("Image upload failed: $e");
    }
  }

  Future<void> addProduct(Product product) async {
    await _db.collection('products').add(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }

  // --- Orders Logic ---
  Future<void> placeFullOrder(String buyerId, Product product, Address address, String paymentMethod) async {
    final order = OrderModel(
      id: '',
      buyerId: buyerId,
      sellerId: product.sellerId,
      product: product,
      address: address,
      paymentMethod: paymentMethod,
      status: 'Processing',
      date: DateTime.now(),
    );
    await _db.collection('orders').add(order.toMap());
  }

  Stream<List<OrderModel>> getSellerOrders(String sellerId) {
    return _db.collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => OrderModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _db.collection('orders').doc(orderId).update({'status': newStatus});
  }
}
