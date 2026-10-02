import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_client.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final api = ApiClient.instance;

    await api.initialize();

    await Future.delayed(
      const Duration(seconds: 1),
    );

    if (!mounted) return;

    if (!api.isAuthenticated) {
      context.go('/login');
      return;
    }

    try {
      await AuthService().me();

      if (!mounted) return;

      context.go('/home');
    } catch (_) {
      await api.clearToken();

      if (!mounted) return;

      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration:
            const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF008C95),
              Color(0xFF006D75),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Icon(
                Icons.restaurant,
                size: 90,
                color: Colors.white,
              ),

              SizedBox(height: 20),

              Text(
                'Resto Kay-Y',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              SizedBox(height: 8),

              Text(
                'Bon manje, bon sèvis.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),

              SizedBox(height: 35),

              CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}