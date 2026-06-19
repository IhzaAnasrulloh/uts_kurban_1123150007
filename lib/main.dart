import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart' as fb;
import 'package:uts_kurban_1123150007/core/routes/app_router.dart';
import 'package:uts_kurban_1123150007/core/theme/app_theme.dart';
import 'package:uts_kurban_1123150007/features/auth/presentation/providers/auth_provider.dart';
import 'package:uts_kurban_1123150007/features/auth/presentation/providers/cart_provider.dart';
import 'package:uts_kurban_1123150007/features/auth/presentation/providers/product_provider.dart';
import 'package:uts_kurban_1123150007/core/services/kurban_connect_service.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await fb.Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await KurbanConnectService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paket Kurban',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,

      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.generateRoute,
      routes: AppRouter.routes,
    );
  }
}