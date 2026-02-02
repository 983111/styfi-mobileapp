class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String image;
  final String description;
  final String seller;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.image,
    required this.description,
    required this.seller,
  });
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

// Result wrapper for API responses that can be image or text
class AiResult {
  final String type; // 'image' or 'guide'
  final String data;

  AiResult({required this.type, required this.data});
}
