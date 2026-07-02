import 'package:flutter/material.dart';
import 'package:uts_kurban_1123150007/core/guard/auth_guard.dart';
import 'package:uts_kurban_1123150007/features/auth/presentation/pages/cart_page.dart';
import 'package:uts_kurban_1123150007/features/auth/presentation/pages/dashboard_page.dart';
import 'package:uts_kurban_1123150007/features/auth/presentation/pages/login_page.dart';
import 'package:uts_kurban_1123150007/features/auth/presentation/pages/register_page.dart';
import 'package:uts_kurban_1123150007/features/auth/presentation/pages/verify_email_page.dart';
import 'package:uts_kurban_1123150007/features/order/presentation/pages/checkout_page.dart';
import 'package:uts_kurban_1123150007/features/order/presentation/pages/payment_pending_page.dart';
import 'package:uts_kurban_1123150007/features/order/presentation/pages/order_success_page.dart';
import 'package:uts_kurban_1123150007/features/order/presentation/pages/payment_failed_page.dart';
import 'package:uts_kurban_1123150007/features/order/presentation/pages/history_page.dart';

import 'package:uts_kurban_1123150007/features/order/presentation/pages/payment_callback_handler_page.dart';

class AppRouter {
  static const String splash      = '/';
  static const String login       = '/login';
  static const String register    = '/register';
  static const String verifyEmail = '/verify-email';
  static const String dashboard   = '/dashboard';
  static const String cart         = '/cart'; 
  static const String checkout     = '/checkout';
  static const String paymentPending = '/payment-pending';
  static const String orderSuccess = '/order-success';
  static const String paymentFailed = '/payment-failed';
  static const String history      = '/history';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    if (settings.name != null && settings.name!.startsWith('/callback')) {
      final uri = Uri.parse(settings.name!);
      return MaterialPageRoute(builder: (_) => PaymentCallbackHandlerPage(uri: uri));
    }

    switch (settings.name) {
      case paymentPending:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (_) => PaymentPendingPage(
              orderId: args['orderId'],
              amount: args['amount'],
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Error PaymentPending'))));
      case paymentFailed:
        final args = settings.arguments as Map<String, dynamic>?;
        final message = args?['message'] ?? 'Saldo E-Wallet Anda tidak mencukupi.';
        return MaterialPageRoute(builder: (_) => PaymentFailedPage(message: message));
      default:
        return null;
    }
  }

  static Map<String, WidgetBuilder> get routes => {
    splash:      (_) => const AuthGuard(child: DashboardPage()),
    login:       (_) => const LoginPage(),
    register:    (_) => const RegisterPage(),
    verifyEmail: (_) => const VerifyEmailPage(),
    dashboard:   (_) => AuthGuard(child: DashboardPage()),
    cart:        (_) => const CartPage(),
    checkout:    (_) => const CheckoutPage(),
    orderSuccess:(_) => const OrderSuccessPage(),
    history:     (_) => const HistoryPage(),
  };
}