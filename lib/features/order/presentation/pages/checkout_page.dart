import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uts_kurban_1123150007/features/auth/presentation/providers/cart_provider.dart';
import 'package:uts_kurban_1123150007/core/routes/app_router.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _selectedPayment = 'kurban_connect';

  @override
  void dispose() {
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    final str = price.toInt().toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Checkout', style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProv, _) {
          final cart = cartProv.cart;
          if (cart == null || cart.items.isEmpty) {
            return const Center(child: Text('Keranjang kosong', style: TextStyle(color: Colors.white)));
          }

          int totalItems = cart.items.fold(0, (sum, item) => sum + item.quantity);
          double totalPrice = cart.total;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Ringkasan Pesanan'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ...cart.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.product.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text('${item.quantity} x ${_formatPrice(item.product.price)}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Text(_formatPrice(item.subtotal), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      }).toList(),
                      const Divider(color: Colors.white24, height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Item', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                          Text('$totalItems', style: const TextStyle(color: Colors.blueAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                _buildSectionTitle('Alamat Pengiriman'),
                const SizedBox(height: 12),
                _buildTextField(_addressCtrl, 'Masukkan alamat lengkap pengiriman...', maxLines: 3),

                const SizedBox(height: 24),
                _buildSectionTitle('Catatan (opsional)'),
                const SizedBox(height: 12),
                _buildTextField(_notesCtrl, 'Tambahkan catatan untuk penjual...', maxLines: 2),

                const SizedBox(height: 24),
                _buildSectionTitle('Metode Pembayaran'),
                const SizedBox(height: 12),
                
                _buildPaymentMethod(
                  id: 'kurban_connect',
                  title: 'Kurban Connect (Global Institute)',
                  subtitle: 'Bayar instant dengan Dompet Kampus Global',
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: Colors.tealAccent,
                ),
                const SizedBox(height: 12),
                _buildPaymentMethod(
                  id: 'transfer',
                  title: 'Transfer Bank',
                  subtitle: 'BCA, Mandiri, BNI, BRI',
                  icon: Icons.account_balance_outlined,
                  iconColor: Colors.blueAccent,
                ),
                const SizedBox(height: 12),
                _buildPaymentMethod(
                  id: 'va',
                  title: 'Virtual Account',
                  subtitle: 'Nomor VA otomatis digenerate',
                  icon: Icons.school_outlined,
                  iconColor: Colors.orangeAccent,
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProv, _) {
          final total = cartProv.cart?.total ?? 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -2))],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Pembayaran', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        Text(_formatPrice(total), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (_addressCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alamat pengiriman wajib diisi'), backgroundColor: Colors.red));
                        return;
                      }

                      if (_selectedPayment != 'kurban_connect') {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saat ini hanya metode Kurban Connect yang didukung untuk simulasi integrasi.')));
                        return;
                      }

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
                    child: const Text('Buat Pesanan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700));
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildPaymentMethod({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    final isSelected = _selectedPayment == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.purpleAccent : Colors.white12, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? Colors.purpleAccent : Colors.white38, width: 2),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.purpleAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
