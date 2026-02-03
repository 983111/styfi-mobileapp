import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- PRODUCTS ---
  
  // Renamed back to 'getProducts' to match existing screens
  Stream<List<Product>> getProducts() {
    return _db.collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
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

  Future<void> addProduct(Product product) async {
    await _db.collection('products').add(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }

  // --- IMAGES (Supabase) ---
  Future<String> uploadImage(File imageFile, String folder) async {
    // FIX: Define variables outside the try block so they are visible in catch
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = '$folder/$fileName';

    try {
      // Attempt upload
      await _supabase.storage.from('products').upload(
        path, 
        imageFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
      
      return _supabase.storage.from('products').getPublicUrl(path);

    } catch (e) {
      // If bucket is missing, try to create it
      if (e.toString().contains('not found') || e.toString().contains('404')) {
         print("Bucket not found, attempting to create...");
         try {
           await _supabase.storage.createBucket('products', const BucketOptions(public: true));
           
           // Retry upload using the same 'path' variable
           await _supabase.storage.from('products').upload(
             path, 
             imageFile,
             fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
           );
           
           return _supabase.storage.from('products').getPublicUrl(path);
         } catch (createErr) {
           throw Exception("Failed to create bucket or upload: $createErr");
         }
      }
      rethrow;
    }
  }

  // --- ORDERS ---

  // Restored 'placeFullOrder' to match Checkout Screen
  Future<void> placeFullOrder(String buyerId, Product product, Address address, String paymentMethod) async {
    final order = OrderModel(
      id: '',
      buyerId: buyerId,
      sellerId: product.sellerId,
      product: product,
      address: address,
      paymentMethod: paymentMethod,
      status: 'Ordered',
      date: DateTime.now(),
    );
    await _db.collection('orders').add(order.toMap());
  }

  Stream<List<OrderModel>> getSellerOrders(String sellerId) {
    return _db.collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => OrderModel.fromMap(doc.data(), doc.id)).toList());
  }
}
