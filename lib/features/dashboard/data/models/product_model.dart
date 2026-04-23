import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String category;
  final String imageUrl;
  final bool isActive;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    required this.imageUrl,
    required this.isActive,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      // ✅ Handle both 'id' and 'ID' (GORM returns 'ID')
      id: (json['ID'] ?? json['id'] ?? 0) as int,
      name: (json['name'] ?? json['Name'] ?? '') as String,
      description: (json['description'] ?? json['Description'] ?? '') as String,
      // ✅ Handle price sebagai int atau double
      price: (json['price'] ?? json['Price'] ?? 0).toDouble(),
      stock: (json['stock'] ?? json['Stock'] ?? 0) as int,
      category: (json['category'] ?? json['Category'] ?? '') as String,
      imageUrl: (json['image_url'] ?? json['ImageURL'] ?? '') as String,
      isActive: (json['is_active'] ?? json['IsActive'] ?? true) as bool,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        stock,
        category,
        imageUrl,
        isActive,
      ];
}