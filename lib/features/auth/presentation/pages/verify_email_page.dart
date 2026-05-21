import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uts_kurban_1123150007/core/routes/app_router.dart';
import 'package:uts_kurban_1123150007/features/auth/presentation/providers/auth_provider.dart';

import 'package:uts_kurban_1123150007/core/constants/app_colors.dart';
import 'package:uts_kurban_1123150007/features/auth/presentation/widgets/auth_header.dart';
import 'package:uts_kurban_1123150007/features/auth/presentation/widgets/custom_button.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  Timer? _timer;
  bool _resendCooldown = false;
  int _countdown = 60;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted) return;

      final auth = context.read<AuthProvider>();
      final verified = await auth.checkEmailVerified();

      if (verified && mounted) {
        _timer?.cancel();
        Navigator.pushReplacementNamed(context, AppRouter.dashboard);
      }
    });
  }

  Future<void> _resendEmail() async {
    if (_resendCooldown) return;

    await context.read<AuthProvider>().resendVerificationEmail();

    setState(() {
      _resendCooldown = true;
      _countdown = 60;
    });

    Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;

      setState(() {
        _countdown--;
      });

      if (_countdown <= 0) {
        t.cancel();
        setState(() {
          _resendCooldown = false;
        });
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email verifikasi sudah dikirim ulang'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().firebaseUser;

    return Container(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AuthHeader(
                      icon: Icons.mark_email_unread_outlined,
                      title: 'Verifikasi Email',
                      subtitle:
                          'Silakan cek email kamu untuk verifikasi akun.',
                      iconColor: Colors.white,
                    ),

                    const SizedBox(height: 24),

                    // Email
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user?.email ?? '-',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Loading
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Menunggu verifikasi...',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Resend Email
                    CustomButton(
                      label: _resendCooldown
                          ? 'Kirim Ulang ($_countdown detik)'
                          : 'Kirim Ulang Email',
                      variant: ButtonVariant.outlined,
                      onPressed: _resendCooldown ? null : _resendEmail,
                    ),

                    const SizedBox(height: 16),

                    // Logout
                    CustomButton(
                      label: 'Ganti Akun / Logout',
                      variant: ButtonVariant.text,
                      onPressed: () {
                        context.read<AuthProvider>().logout();
                        Navigator.pushReplacementNamed(
                            context, AppRouter.login);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}