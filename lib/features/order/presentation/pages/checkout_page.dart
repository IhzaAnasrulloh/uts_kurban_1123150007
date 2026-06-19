import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uts_kurban_1123150007/features/auth/presentation/providers/cart_provider.dart';
import 'package:uts_kurban_1123150007/core/routes/app_router.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Consumer<CartProvider>(
        builder: (context, cartProv, _) {
          final total = cartProv.cart?.total ?? 0;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Pilih Metode Pembayaran',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                  child: ListTile(
                    leading: const Icon(Icons.account_balance_wallet, color: Color(0xFF1A237E)),
                    title: const Text('Kurban Connect'),
                    subtitle: const Text('Bayar via aplikasi Kurban Connect'),
                    trailing: const Icon(Icons.check_circle, color: Color(0xFF1A237E)),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Tagihan', style: TextStyle(fontSize: 16)),
                    Text(
                      'Rp. ${total.toInt()}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    final orderId = DateTime.now().millisecondsSinceEpoch;
                    Navigator.pushNamed(
                      context, 
                      AppRouter.paymentPending,
                      arguments: {
                        'orderId': orderId,
                        'amount': total,
                      },
                    );
                  },
                  child: const Text('Buat Pesanan'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
