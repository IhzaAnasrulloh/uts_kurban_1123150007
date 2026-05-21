import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:uts_kurban_1123150007/core/constants/api_constants.dart';
import 'package:uts_kurban_1123150007/core/services/dio_client.dart';
import 'package:uts_kurban_1123150007/features/dashboard/data/models/product_model.dart';

enum ProductStatus { initial, loading, loaded, error }

class ProductProvider extends ChangeNotifier {
  ProductStatus _status = ProductStatus.initial;
  List<ProductModel> _products = [];
  String? _error;
  bool _disposed = false;

  ProductStatus get status => _status;
  List<ProductModel> get products => _products;
  String? get error => _error;
  bool get isLoading => _status == ProductStatus.loading;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> fetchProducts() async {
    _status = ProductStatus.loading;
    _error = null;
    _safeNotify();

    try {
      final response = await DioClient.instance.get(ApiConstants.products);

      // ✅ Debug: print response untuk lihat struktur JSON
      debugPrint('[PRODUCTS RESPONSE] ${response.data}');

      // Backend mengembalikan { "success": true, "data": [...], "meta": {...} }
      final rawData = response.data['data'];

      if (rawData == null) {
        _error = 'Data produk kosong dari server';
        _status = ProductStatus.error;
        _safeNotify();
        return;
      }

      final List<dynamic> data = rawData as List<dynamic>;
      _products = data.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
      _status = ProductStatus.loaded;
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Gagal memuat produk (${e.type})';
      _status = ProductStatus.error;
    } catch (e) {
      _error = 'Gagal parsing data: $e';
      _status = ProductStatus.error;
    }

    _safeNotify();
  }
}