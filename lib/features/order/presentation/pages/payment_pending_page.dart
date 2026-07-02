import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:uts_kurban_1123150007/core/services/kurban_connect_service.dart';
import 'package:uts_kurban_1123150007/core/routes/app_router.dart';
import 'package:uts_kurban_1123150007/features/auth/presentation/providers/cart_provider.dart';

import 'package:uts_kurban_1123150007/features/order/presentation/providers/history_provider.dart';

class PaymentPendingPage extends StatefulWidget {
  final int orderId;
  final double amount;

  const PaymentPendingPage({super.key, required this.orderId, required this.amount});

  @override
  State<PaymentPendingPage> createState() => _PaymentPendingPageState();
}

class _PaymentPendingPageState extends State<PaymentPendingPage> with WidgetsBindingObserver {
  bool _payLaunched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Dihapus agar tidak langsung otomatis membuka aplikasi pembayaran
    // WidgetsBinding.instance.addPostFrameCallback((_) => _launchGlobalInstitutePay());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _payLaunched) {
      // Fallback API check can be placed here if real backend is used
    }
  }

  void _onPaymentSuccess() {}

  Future<void> _launchGlobalInstitutePay() async {
    final deeplinkUrl = KurbanConnectService.buildDeeplinkUrl(
      orderId: widget.orderId,
      amount: widget.amount,
    );

    final uri = Uri.parse(deeplinkUrl);

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
      if (launched) {
        setState(() => _payLaunched = true);
        return;
      }
    } catch (e) {
      debugPrint('Error launching url: $e');
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Aplikasi Kurban Connect tidak merespons. Pastikan sudah di-install dan dijalankan di emulator yang SAMA.'),
        backgroundColor: Colors.red,
      ),
    );
    setState(() => _payLaunched = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // AppColors.background
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Selesaikan Pembayaran',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Circular Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E), // AppColors.surface
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF6A1B9A), width: 2), // AppColors.primary
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                size: 40,
                color: Color(0xFFAB47BC), // AppColors.accent
              ),
            ),
            const SizedBox(height: 24),
            
            // Title & Amount
            const Text(
              'Bayar dengan Kurban Connect',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Order #${widget.orderId} · Rp. ${widget.amount.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Color(0xFFAB47BC), // AppColors.accent
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),
            
            // Steps Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E), // AppColors.surface
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  _buildStepItem(
                    isCompleted: _payLaunched,
                    stepNumber: '1',
                    text: _payLaunched ? 'Aplikasi Kurban Connect sudah dibuka' : 'Buka aplikasi Kurban Connect',
                  ),
                  const SizedBox(height: 20),
                  _buildStepItem(
                    isCompleted: false,
                    stepNumber: '2',
                    text: 'Konfirmasi pembayaran Rp. ${widget.amount.toStringAsFixed(0)} di Kurban Connect',
                  ),
                  const SizedBox(height: 20),
                  _buildStepItem(
                    isCompleted: false,
                    stepNumber: '3',
                    text: 'Kembali ke aplikasi — status otomatis diperbarui',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Primary Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _launchGlobalInstitutePay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A), // AppColors.primary
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.open_in_new, size: 20),
                label: Text(
                  _payLaunched ? 'Buka Kembali Kurban Connect' : 'Buka Kurban Connect',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Secondary Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mengecek status pembayaran...')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFAB47BC), // AppColors.accent
                  side: const BorderSide(color: Color(0xFFAB47BC)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text(
                  'Cek Status Pembayaran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Bottom Status Text
            if (_payLaunched)
              const Text(
                'Sedang menunggu konfirmasi pembayaran dari Kurban Connect...',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem({required bool isCompleted, required String stepNumber, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isCompleted ? Colors.green : const Color(0xFF1E1E1E), // AppColors.surface
            shape: BoxShape.circle,
            border: isCompleted ? null : Border.all(color: const Color(0xFFAB47BC), width: 1.5),
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : Text(
                  stepNumber,
                  style: const TextStyle(color: Color(0xFFAB47BC), fontSize: 12, fontWeight: FontWeight.bold),
                ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}
