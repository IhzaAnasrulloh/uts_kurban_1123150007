import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uts_kurban_1123150007/core/routes/app_router.dart';
import 'package:uts_kurban_1123150007/features/auth/presentation/providers/auth_provider.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final auth = context.read<AuthProvider>();

      final verified = await auth.checkEmailVerified();

      if (!mounted) return;

      if (verified) {
        _timer?.cancel();
        Navigator.pushReplacementNamed(context, AppRouter.dashboard);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().firebaseUser;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email, size: 80),
            const SizedBox(height: 20),

            const Text(
              'Cek email kamu',
              style: TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 10),

            Text(user?.email ?? '-'),

            const SizedBox(height: 30),

            const CircularProgressIndicator(),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                final auth = context.read<AuthProvider>();
                final verified = await auth.checkEmailVerified();

                if (verified && context.mounted) {
                  Navigator.pushReplacementNamed(
                      context, AppRouter.dashboard);
                }
              },
              child: const Text('Saya sudah verifikasi'),
            ),
          ],
        ),
      ),
    );
  }
}