import 'package:flutter/material.dart';
import 'package:uts_kurban_1123150007/core/routes/app_router.dart';

class PaymentFailedPage extends StatelessWidget {
  final String message;
  const PaymentFailedPage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // AppColors.background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 100, color: Color(0xFFCF6679)), // AppColors.error
              const SizedBox(height: 24),
              const Text(
                'Pembayaran Gagal',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRouter.history);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A), // AppColors.primary
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Lihat Histori Pembelian', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, AppRouter.dashboard, (route) => false);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFAB47BC), // AppColors.accent
                    side: const BorderSide(color: Color(0xFFAB47BC)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Kembali ke Beranda', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
