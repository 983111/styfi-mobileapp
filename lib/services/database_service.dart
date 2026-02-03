import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import '../models.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

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

  // --- Image Upload ---
  Future<String> uploadProductImage(File imageFile, String uid) async {
    // FIX: Define variables OUTSIDE the try block so they are accessible in catch
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String path = '$uid/$fileName';

    try {
      await _supabase.storage.from('products').upload(
        path,
        imageFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      return _supabase.storage.from('products').getPublicUrl(path);
    } catch (e) {
      // Recovery for missing bucket
      if (e.toString().contains('not found') || e.toString().contains('404')) {
         try {
           await _supabase.storage.createBucket('products', const BucketOptions(public: true));
           // Now 'path' is accessible here because we defined it outside
           await _supabase.storage.from('products').upload(path, imageFile);
           return _supabase.storage.from('products').getPublicUrl(path);
         } catch (_) { throw e; }
      }
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
  
  // 1. Place Order
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

  // 2. Get Seller Orders
  Stream<List<OrderModel>> getSellerOrders(String sellerId) {
    return _db.collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => OrderModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // 3. Get Buyer Orders
  Stream<List<OrderModel>> getBuyerOrders(String buyerId) {
    return _db.collection('orders')
        .where('buyerId', isEqualTo: buyerId)
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
