// lib/models.dart

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

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role == UserRole.seller ? 'seller' : 'buyer',
    };
  }
}

class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String image;
  final String description;
  final String sellerId; // Renamed from 'seller' to 'sellerId' for consistency

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.image,
    required this.description,
    required this.sellerId,
  });

  // Convert from Firestore Document
  factory Product.fromMap(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? 'General',
      image: data['image'] ?? '',
      description: data['description'] ?? '',
      sellerId: data['sellerId'] ?? '',
    );
  }

  // Convert to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'image': image,
      'description': description,
      'sellerId': sellerId,
    };
  }
}

class OutfitSuggestion {
  final String name;
  final String reason;
  final String estimatedPrice;
  final String color;

  OutfitSuggestion({
    required this.name,
    required this.reason,
    required this.estimatedPrice,
    required this.color,
  });

  factory OutfitSuggestion.fromJson(Map<String, dynamic> json) {
    return OutfitSuggestion(
      name: json['name'] ?? '',
      reason: json['reason'] ?? '',
      estimatedPrice: json['estimatedPrice'] ?? '',
      color: json['color'] ?? '',
    );
  }
}

class TrendReport {
  final String trendName;
  final String description;
  final int popularityScore;
  final List<String> keyKeywords;

  TrendReport({
    required this.trendName,
    required this.description,
    required this.popularityScore,
    required this.keyKeywords,
  });

  factory TrendReport.fromJson(Map<String, dynamic> json) {
    return TrendReport(
      trendName: json['trendName'] ?? '',
      description: json['description'] ?? '',
      popularityScore: json['popularityScore'] ?? 0,
      keyKeywords: List<String>.from(json['keyKeywords'] ?? []),
    );
  }
}

class AiResult {
  final String type;
  final String data;
  AiResult({required this.type, required this.data});
}
