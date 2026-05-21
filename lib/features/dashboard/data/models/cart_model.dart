class CartProductModel {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;
  final int stock;

  const CartProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.stock,
  });

  factory CartProductModel.fromJson(Map<String, dynamic> json) =>
      CartProductModel(
        id: json['ID'] as int? ?? json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        imageUrl: json['image_url'] as String? ?? '',
        category: json['category'] as String? ?? '',
        stock: json['stock'] as int? ?? 0,
      );
}

class CartItemModel {
  final int id;
  final int productId;
  final CartProductModel product;
  final int quantity;
  final double subtotal;

  const CartItemModel({
    required this.id,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.subtotal,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    // Backend pakai "ID" (gorm.Model) — bukan "id"
    final id = json['ID'] as int? ?? json['id'] as int? ?? 0;

    final product = CartProductModel.fromJson(
      json['product'] as Map<String, dynamic>? ?? {},
    );
    final quantity = json['quantity'] as int? ?? 0;

    // Backend tidak kirim subtotal — hitung manual
    final subtotal = product.price * quantity;

    return CartItemModel(
      id: id,
      productId: json['product_id'] as int? ?? 0,
      product: product,
      quantity: quantity,
      subtotal: subtotal,
    );
  }
}

class CartModel {
  final List<CartItemModel> items;
  final double total;
  final int itemCount;

  const CartModel({
    required this.items,
    required this.total,
    required this.itemCount,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? [])
        .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // Backend kirim "total_price" dan "total_items"
    final apiTotal = (json['total_price'] as num?)?.toDouble();
    final total = apiTotal ?? items.fold<double>(0.0, (sum, i) => sum + i.subtotal);

    final apiItemCount = json['total_items'] as int?;
    // Hitung jumlah produk total (sum quantity), bukan jumlah jenis item
    final itemCount = apiItemCount ??
        items.fold<int>(0, (sum, i) => sum + i.quantity);

    return CartModel(
      items: items,
      total: total,
      itemCount: itemCount,
    );
  }
}