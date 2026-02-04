import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // --- MARKETPLACE & PRODUCTS ---

  // 1. Get ALL products (For Marketplace Screen)
  Stream<List<Product>> getProducts() {
    return _db.collection('products')
        .orderBy('price', descending: false) // Optional sorting
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap(doc.data(), doc.id))
            .toList());
  }

  // 2. Get Seller's Products (For Seller Dashboard)
  Stream<List<Product>> getSellerProducts(String sellerId) {
    return _db.collection('products')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap(doc.data(), doc.id))
            .toList());
  }

  // 3. Add a new Product
  Future<void> addProduct(Product product) async {
    await _db.collection('products').add(product.toMap());
  }

  // 4. Delete a Product
  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }

  // 5. Upload Product Image to Firebase Storage
  Future<String> uploadProductImage(File file, String userId) async {
    // Create a unique path for the image
    final ref = _storage.ref().child('products/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');
    
    // Upload the file
    await ref.putFile(file);
    
    // Get the download URL
    return await ref.getDownloadURL();
  }

  // --- ORDERS & CHECKOUT ---

  // 6. Place a Full Order (For Checkout Screen)
  Future<void> placeFullOrder(String buyerId, Product product, Address address, String paymentMethod) async {
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();
    
    final order = OrderModel(
      id: orderId,
      buyerId: buyerId,
      sellerId: product.sellerId,
      product: product,
      address: address,
      paymentMethod: paymentMethod, // <--- ADDED THIS LINE (Fixes the error)
      status: 'Processing',
      date: DateTime.now(),
    );

    // Save to Firestore
    await _db.collection('orders').doc(orderId).set(order.toMap());
  }

  // 7. Get User's Orders (For Buyer Profile)
  Stream<List<OrderModel>> getUserOrders(String uid) {
    return _db.collection('orders')
        .where('buyerId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs
              .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
              .toList();
          orders.sort((a, b) => b.date.compareTo(a.date)); // Sort by date desc
          return orders;
        });
  }

  // 8. Get Seller's Incoming Orders (For Seller Dashboard)
  Stream<List<OrderModel>> getSellerOrders(String uid) {
    return _db.collection('orders')
        .where('sellerId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs
              .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
              .toList();
          orders.sort((a, b) => b.date.compareTo(a.date));
          return orders;
        });
  }

  // 9. Update Order Status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _db.collection('orders').doc(orderId).update({'status': newStatus});
  }
}
