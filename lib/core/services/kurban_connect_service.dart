import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

class PaymentCallbackData {
  final String status;
  final String? reference;
  final String? transactionId;

  const PaymentCallbackData({
    required this.status,
    this.reference,
    this.transactionId,
  });

  bool get isSuccess => status == 'success';
}

class KurbanConnectService {
  static final KurbanConnectService _instance = KurbanConnectService._();

  factory KurbanConnectService() => _instance;

  KurbanConnectService._();

  final _callbackController = StreamController<PaymentCallbackData>.broadcast();

  Stream<PaymentCallbackData> get onCallback => _callbackController.stream;

  PaymentCallbackData? _pendingCallback;

  PaymentCallbackData? consumePendingCallback() {
    final data = _pendingCallback;
    _pendingCallback = null;
    return data;
  }

  Future<void> init() async {
    final appLinks = AppLinks();

    try {
      final uri = await appLinks.getInitialLink();
      if (uri != null) _handleUri(uri, isColdStart: true);
    } catch (_) {}

    appLinks.uriLinkStream.listen(_handleUri);
  }

  void _handleUri(Uri uri, {bool isColdStart = false}) {
    debugPrint('[KurbanConnectService] URI diterima: $uri');
    debugPrint('[KurbanConnectService] Cold start: $isColdStart');

    if (uri.scheme == 'pasarmalam' && uri.host == 'payment-callback' && uri.path == '/callback') {
      final data = PaymentCallbackData(
        status: uri.queryParameters['status'] ?? 'unknown',
        reference: uri.queryParameters['reference'],
        transactionId: uri.queryParameters['transaction_id'],
      );

      debugPrint('[KurbanConnectService] Callback params: ${uri.queryParameters}');

      if (isColdStart) _pendingCallback = data;

      _callbackController.add(data);
    }
  }

  static String buildDeeplinkUrl({
    required int orderId,
    required double amount,
    String? description,
  }) {
    final uri = Uri(
      scheme: 'dompetkampus',
      host: 'pay',
      queryParameters: {
        'merchant_id': 'MCH_PASAR_MALAM',
        'merchant_name': 'Pasar Malam',
        'amount': amount.toInt().toString(),
        'description': (description != null && description.isNotEmpty)
            ? description
            : 'Order #$orderId',
        'reference': 'INV-$orderId',
        'callback': 'pasarmalam://payment-callback/callback',
      },
    );
    return uri.toString();
  }
}
