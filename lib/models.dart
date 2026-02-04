import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { buyer, seller }

class AppUser {
  final String uid;
  final String email;
  final UserRole role;

  AppUser({required this.uid, required this.email, required this.role});

  factory AppUser.fromMap(Map<String, dynamic> data, String uid) {
    return AppUser(
      uid: uid,
      email: data['email'] ?? '',
      role: data['role'] == 'seller' ? UserRole.seller : UserRole.buyer,
    );
  }
}

class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String image;
  final String description;
  final String sellerId;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.image,
    required this.description,
    required this.sellerId,
  });

  factory Product.fromMap(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? 'Unknown Product',
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? 'General',
      image: data['image'] ?? '',
      description: data['description'] ?? '',
      sellerId: data['sellerId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'image': image,
      'description': description,
      'sellerId': sellerId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

class Address {
  final String fullName;
  final String street;
  final String city;
  final String zip;
  final String phone;

  Address({required this.fullName, required this.street, required this.city, required this.zip, required this.phone});

  Map<String, dynamic> toMap() => {
    'fullName': fullName, 'street': street, 'city': city, 'zip': zip, 'phone': phone
  };

  factory Address.fromMap(Map<String, dynamic> map) => Address(
    fullName: map['fullName'] ?? 'Unknown', 
    street: map['street'] ?? '', 
    city: map['city'] ?? '', 
    zip: map['zip'] ?? '', 
    phone: map['phone'] ?? ''
  );
}

class OrderModel {
  final String id;
  final String buyerId;
  final String sellerId;
  final Product product;
  final Address address;
  final String paymentMethod;
  final String status;
  final DateTime date;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.product,
    required this.address,
    required this.paymentMethod,
    required this.status,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'buyerId': buyerId,
      'sellerId': sellerId,
      'product': product.toMap(),
      'address': address.toMap(),
      'paymentMethod': paymentMethod,
      'status': status,
      'date': Timestamp.fromDate(date),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> data, String id) {
    return OrderModel(
      id: id,
      buyerId: data['buyerId'] ?? '',
      sellerId: data['sellerId'] ?? '',
      // Safely handle missing product data
      product: Product.fromMap(data['product'] != null ? data['product'] as Map<String, dynamic> : {}, ''),
      // Safely handle missing address data
      address: Address.fromMap(data['address'] != null ? data['address'] as Map<String, dynamic> : {}),
      paymentMethod: data['paymentMethod'] ?? 'COD',
      status: data['status'] ?? 'Processing',
      date: data['date'] != null ? (data['date'] as Timestamp).toDate() : DateTime.now(),
    );
  }
}

// Keep these for AI features
class OutfitSuggestion {
  final String name; final String reason; final String estimatedPrice; final String color;
  OutfitSuggestion({required this.name, required this.reason, required this.estimatedPrice, required this.color});
  factory OutfitSuggestion.fromJson(Map<String, dynamic> json) => OutfitSuggestion(
    name: json['name']??'', reason: json['reason']??'', estimatedPrice: json['estimatedPrice']??'', color: json['color']??'');
}

class TrendReport {
  final String trendName; final String description; final int popularityScore; final List<String> keyKeywords;
  TrendReport({required this.trendName, required this.description, required this.popularityScore, required this.keyKeywords});
  factory TrendReport.fromJson(Map<String, dynamic> json) => TrendReport(
      trendName: json['trendName']??'', description: json['description']??'', popularityScore: json['popularityScore']??0, keyKeywords: List<String>.from(json['keyKeywords']??[]));
}

class AiResult {
  final String type; final String data;
  AiResult({required this.type, required this.data});
}
