import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  Future<void> _logout(
    BuildContext context,
  ) async {
    await AuthService().logout();

    if (!context.mounted) return;

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Resto Kay-Y',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                _logout(context),
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(22),
              decoration:
                  BoxDecoration(
                gradient:
                    const LinearGradient(
                  colors: [
                    Color(0xFF008C95),
                    Color(0xFF006D75),
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjou 👋',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    'Kisa ou ta renmen manje jodi a?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 15),

                  Text(
                    'Dekouvri bon gou manje Resto Kay-Y yo.',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Kòmande fasil',
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: _HomeCard(
                    icon:
                        Icons.restaurant_menu,
                    title: 'Menu',
                    subtitle:
                        'Gade tout plat yo',
                    onTap: () =>
                        context.go('/menu'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _HomeCard(
                    icon:
                        Icons.shopping_cart,
                    title: 'Panier',
                    subtitle:
                        'Gade kòmand ou',
                    onTap: () =>
                        context.go('/cart'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _HomeCard(
                    icon:
                        Icons.delivery_dining,
                    title: 'Livrezon',
                    subtitle:
                        'Fè yo livre ba ou',
                    onTap: () {},
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _HomeCard(
                    icon:
                        Icons.receipt_long,
                    title: 'Kòmand',
                    subtitle:
                        'Swiv kòmand ou',
                    onTap: () =>
                        context.go('/orders'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      bottomNavigationBar:
          NavigationBar(
        selectedIndex: 0,
        onDestinationSelected:
            (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/menu');
              break;
            case 2:
              context.go('/cart');
              break;
            case 3:
              context.go('/orders');
              break;
            case 4:
              context.go('/profile');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon:
                Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon:
                Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          NavigationDestination(
            icon:
                Icon(Icons.shopping_cart_outlined),
            selectedIcon:
                Icon(Icons.shopping_cart),
            label: 'Panier',
          ),
          NavigationDestination(
            icon:
                Icon(Icons.receipt_long_outlined),
            label: 'Kòmand',
          ),
          NavigationDestination(
            icon:
                Icon(Icons.person_outline),
            selectedIcon:
                Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(20),
      child: Container(
        padding:
            const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 15,
              color:
                  Colors.black.withValues(
                alpha: 0.06,
              ),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 35,
              color:
                  const Color(0xFF008C95),
            ),

            const SizedBox(height: 15),

            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              subtitle,
              style: const TextStyle(
                color:
                    Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}