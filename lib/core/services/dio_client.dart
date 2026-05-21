import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uts_kurban_1123150007/core/constants/api_constants.dart';
import 'package:uts_kurban_1123150007/core/constants/secure_storage.dart';

class DioClient {
  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorageService.getToken();

          debugPrint('======================');
          debugPrint('[REQUEST] ${options.method} ${options.uri}');
          debugPrint('[TOKEN] ${token != null ? 'ada' : 'null'}');

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('[RESPONSE] ${response.statusCode}');
          debugPrint('[DATA] ${response.data}');
          debugPrint('======================');

          handler.next(response);
        },
        onError: (error, handler) async {
          debugPrint('======================');
          debugPrint('[ERROR STATUS] ${error.response?.statusCode}');
          debugPrint('[ERROR DATA] ${error.response?.data}');
          debugPrint('[ERROR MESSAGE] ${error.message}');
          debugPrint('[ERROR TYPE] ${error.type}');
          debugPrint('======================');

          // 🔥 Kalau 401 INVALID_TOKEN → refresh lalu retry
          if (error.response?.statusCode == 401) {
            final errorCode = error.response?.data?['error_code'];

            if (errorCode == 'INVALID_TOKEN') {
              debugPrint('[DIO] Token expired, mencoba refresh...');

              final refreshed = await _refreshAndVerifyToken();

              if (refreshed) {
                // Retry request dengan token baru
                final newToken = await SecureStorageService.getToken();
                final opts = error.requestOptions;
                opts.headers['Authorization'] = 'Bearer $newToken';

                try {
                  final retryResponse = await dio.fetch(opts);
                  return handler.resolve(retryResponse);
                } catch (e) {
                  debugPrint('[DIO] Retry gagal: $e');
                  return handler.next(error);
                }
              }
            }

            // Kalau MISSING_TOKEN atau refresh gagal → clear storage
            debugPrint('[DIO] Clear token karena 401');
            await SecureStorageService.clearAll();
          }

          handler.next(error);
        },
      ),
    );

    return dio;
  }

  // 🔥 Refresh Firebase token lalu verify ulang ke backend
  static Future<bool> _refreshAndVerifyToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('[DIO] Tidak ada user Firebase');
        return false;
      }

      // Force refresh Firebase ID Token
      final newFirebaseToken = await user.getIdToken(true);
      debugPrint('[DIO] Firebase token di-refresh');

      // Pakai tempDio supaya tidak kena interceptor (hindari infinite loop)
      final tempDio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final response = await tempDio.post(
        ApiConstants.verifyToken,
        data: {'firebase_token': newFirebaseToken}, // 🔥 field yang benar
      );

      // Ambil JWT dari response.data.access_token
      final backendJwt = response.data['data']?['access_token'];

      if (backendJwt == null) {
        debugPrint('[DIO] access_token tidak ada di response refresh');
        return false;
      }

      await SecureStorageService.saveToken(backendJwt);
      debugPrint('[DIO] Backend JWT baru tersimpan!');

      return true;
    } catch (e) {
      debugPrint('[DIO] Gagal refresh token: $e');
      return false;
    }
  }
}