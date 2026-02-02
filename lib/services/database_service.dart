import 'package:cloud_firestore/cloud_firestore.dart';
import '../models.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get all products (For Marketplace)
  Stream<List<Product>> getProducts() {
    return _db.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Get products for a specific seller (For Seller Dashboard)
  Stream<List<Product>> getSellerProducts(String sellerId) {
    return _db.collection('products')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Add a product
  Future<void> addProduct(Product product) async {
    await _db.collection('products').add(product.toMap());
  }
}
