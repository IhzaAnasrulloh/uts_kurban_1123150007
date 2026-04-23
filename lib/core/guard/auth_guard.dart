import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uts_kurban_1123150007/core/routes/app_router.dart';
import 'package:uts_kurban_1123150007/features/auth/presentation/providers/auth_provider.dart';

class AuthGuard extends StatefulWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  AuthStatus? _lastStatus;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // Hanya navigasi jika status BERUBAH — mencegah infinite loop
        if (auth.status != _lastStatus) {
          _lastStatus = auth.status;

          if (auth.status == AuthStatus.unauthenticated ||
              auth.status == AuthStatus.error) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, AppRouter.login);
            });
          } else if (auth.status == AuthStatus.emailNotVerified) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, AppRouter.verifyEmail);
            });
          }
        }

        if (auth.status == AuthStatus.initial ||
            auth.status == AuthStatus.loading) {
          return const Scaffold(
            backgroundColor: Color(0xFF121212),
            body: Center(
              child: CircularProgressIndicator(color: Colors.purpleAccent),
            ),
          );
        }

        if (auth.status == AuthStatus.authenticated) {
          return widget.child;
        }

        return const Scaffold(
          backgroundColor: Color(0xFF121212),
          body: Center(
            child: CircularProgressIndicator(color: Colors.purpleAccent),
          ),
        );
      },
    );
  }
}