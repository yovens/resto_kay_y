import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/menu/menu_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/splash/splash_screen.dart';

final GoRouter appRouter =
    GoRouter(
  initialLocation: '/splash',

  routes: [
    GoRoute(
      path: '/splash',
      builder: (
        context,
        state,
      ) {
        return const SplashScreen();
      },
    ),

    GoRoute(
      path: '/login',
      builder: (
        context,
        state,
      ) {
        return const LoginScreen();
      },
    ),

    GoRoute(
      path: '/register',
      builder: (
        context,
        state,
      ) {
        return const RegisterScreen();
      },
    ),

    GoRoute(
      path: '/home',
      builder: (
        context,
        state,
      ) {
        return const HomeScreen();
      },
    ),

 GoRoute(
  path: '/menu',
  builder: (
    context,
    state,
  ) {
    return const MenuScreen();
  },
),

    GoRoute(
      path: '/cart',
      builder: (
        context,
        state,
      ) {
        return const _ComingSoonScreen(
          title: 'Panier',
        );
      },
    ),

    GoRoute(
      path: '/orders',
      builder: (
        context,
        state,
      ) {
        return const _ComingSoonScreen(
          title: 'Kòmand mwen yo',
        );
      },
    ),

    GoRoute(
      path: '/profile',
      builder: (
        context,
        state,
      ) {
        return const _ComingSoonScreen(
          title: 'Profil',
        );
      },
    ),
  ],
);

class _ComingSoonScreen
    extends StatelessWidget {
  final String title;

  const _ComingSoonScreen({
    required this.title,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          '$title ap vini...',
          style: const TextStyle(
            fontSize: 20,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }
}