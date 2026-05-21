import 'package:flutter/material.dart';
import 'package:uts_kurban_1123150007/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:uts_kurban_1123150007/features/cart/domain/repositories/cart_repository.dart';
import 'package:uts_kurban_1123150007/features/dashboard/data/models/cart_model.dart';

enum CartStatus { initial, loading, loaded, error }

class CartProvider extends ChangeNotifier {
  final CartRepository _repository = CartRepositoryImpl();

  CartStatus _status = CartStatus.initial;
  CartModel? _cart;
  String? _error;
  bool _isAdding = false;
  bool _disposed = false;

  CartStatus get status => _status;
  CartModel? get cart => _cart;
  String? get error => _error;
  bool get isAdding => _isAdding;
  int get itemCount => _cart?.itemCount ?? 0;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> fetchCart() async {
    _status = CartStatus.loading;
    _error = null;
    _safeNotify();

    try {
      _cart = await _repository.getCart();
      _status = CartStatus.loaded;
    } catch (e) {
      _error = 'Gagal memuat keranjang: $e';
      _status = CartStatus.error;
    }

    _safeNotify();
  }

  Future<bool> addToCart(int productId, int quantity) async {
    _isAdding = true;
    _safeNotify();

    try {
      await _repository.addToCart(productId, quantity);
      await fetchCart();
      _isAdding = false;
      _safeNotify();
      return true;
    } catch (e) {
      _isAdding = false;
      _safeNotify();
      return false;
    }
  }

  Future<void> updateItem(int cartItemId, int quantity) async {
    try {
      await _repository.updateCartItem(cartItemId, quantity);
      await fetchCart();
    } catch (e) {
      _error = 'Gagal update item: $e';
      _safeNotify();
    }
  }

  Future<void> removeItem(int cartItemId) async {
    try {
      await _repository.removeCartItem(cartItemId);
      await fetchCart();
    } catch (e) {
      _error = 'Gagal hapus item: $e';
      _safeNotify();
    }
  }

  Future<void> clearCart() async {
    try {
      await _repository.clearCart();
      _cart = const CartModel(items: [], total: 0, itemCount: 0);
      _status = CartStatus.loaded;
      _safeNotify();
    } catch (e) {
      _error = 'Gagal kosongkan keranjang: $e';
      _safeNotify();
    }
  }
}