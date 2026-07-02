import 'package:flutter/material.dart';
import 'package:uts_kurban_1123150007/features/dashboard/data/models/cart_model.dart';

class HistoryOrder {
  final int orderId;
  final List<CartItemModel> items;
  final double totalAmount;
  final DateTime date;
  final String status;

  HistoryOrder({
    required this.orderId,
    required this.items,
    required this.totalAmount,
    required this.date,
    required this.status,
  });
}

class HistoryProvider with ChangeNotifier {
  final List<HistoryOrder> _orders = [];

  List<HistoryOrder> get orders => _orders;

  void addOrder(HistoryOrder order) {
    _orders.insert(0, order); // Add to the top
    notifyListeners();
  }
}
