import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uts_kurban_1123150007/core/routes/app_router.dart';
import 'package:uts_kurban_1123150007/features/auth/presentation/providers/cart_provider.dart';
import 'package:uts_kurban_1123150007/features/order/presentation/providers/history_provider.dart';

class PaymentCallbackHandlerPage extends StatefulWidget {
  final Uri uri;
  const PaymentCallbackHandlerPage({super.key, required this.uri});

  @override
  State<PaymentCallbackHandlerPage> createState() => _PaymentCallbackHandlerPageState();
}

class _PaymentCallbackHandlerPageState extends State<PaymentCallbackHandlerPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleCallback();
    });
  }

  Future<void> _handleCallback() async {
    final status = widget.uri.queryParameters['status'] ?? 'unknown';
    
    if (status == 'success') {
      final cartProvider = context.read<CartProvider>();
      final historyProvider = context.read<HistoryProvider>();

      if (cartProvider.cart == null) {
        await cartProvider.fetchCart();
      }

      final currentItems = cartProvider.cart?.items ?? [];

      if (currentItems.isNotEmpty) {
        final ref = widget.uri.queryParameters['reference'] ?? '';
        final orderIdStr = ref.replaceAll('INV-', '');
        final orderId = int.tryParse(orderIdStr) ?? DateTime.now().millisecondsSinceEpoch % 10000;
        
        historyProvider.addOrder(
          HistoryOrder(
            orderId: orderId,
            items: List.from(currentItems),
            totalAmount: cartProvider.cart?.total ?? 0,
            date: DateTime.now(),
            status: 'Berhasil',
          ),
        );
      }
      cartProvider.clearCart();
      Navigator.pushReplacementNamed(context, AppRouter.orderSuccess);
    } else {
      Navigator.pushReplacementNamed(context, AppRouter.paymentFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF121212),
      body: Center(
        child: CircularProgressIndicator(color: Colors.purpleAccent),
      ),
    );
  }
}
