import 'package:uts_kurban_1123150007/features/dashboard/data/models/cart_model.dart';

abstract class CartRepository {
  Future<CartModel> getCart();
  Future<void> addToCart(int productId, int quantity);
  Future<void> updateCartItem(int cartItemId, int quantity);
  Future<void> removeCartItem(int cartItemId);
  Future<void> clearCart();
}