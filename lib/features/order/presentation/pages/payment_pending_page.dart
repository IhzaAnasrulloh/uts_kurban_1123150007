import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:uts_kurban_1123150007/core/services/kurban_connect_service.dart';
import 'package:uts_kurban_1123150007/core/routes/app_router.dart';
import 'package:uts_kurban_1123150007/features/auth/presentation/providers/cart_provider.dart';

class PaymentPendingPage extends StatefulWidget {
  final int orderId;
  final double amount;

  const PaymentPendingPage({super.key, required this.orderId, required this.amount});

  @override
  State<PaymentPendingPage> createState() => _PaymentPendingPageState();
}

class _PaymentPendingPageState extends State<PaymentPendingPage> with WidgetsBindingObserver {
  bool _payLaunched = false;
  StreamSubscription<PaymentCallbackData>? _callbackSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) => _launchGlobalInstitutePay());

    final pending = KurbanConnectService().consumePendingCallback();
    if (pending != null && pending.isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onPaymentSuccess());
    }

    _callbackSub = KurbanConnectService().onCallback.listen((data) {
      if (!mounted) return;
      if (data.isSuccess) {
        _onPaymentSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pembayaran gagal (status: ${data.status})'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _callbackSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _payLaunched) {
      // Fallback API check can be placed here if real backend is used
    }
  }

  void _onPaymentSuccess() {
    if (mounted) {
      context.read<CartProvider>().clearCart();
    }
    Navigator.pushReplacementNamed(context, AppRouter.orderSuccess);
  }

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
      appBar: AppBar(title: const Text('Menunggu Pembayaran')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance_wallet, size: 80, color: Color(0xFF1A237E)),
              const SizedBox(height: 24),
              const Text(
                'Lanjutkan pembayaran di aplikasi Kurban Connect.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              if (_payLaunched)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Menunggu konfirmasi pembayaran...', style: TextStyle(color: Colors.grey)),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: _launchGlobalInstitutePay,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E), foregroundColor: Colors.white),
                  child: const Text('Buka Kurban Connect'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
