
import 'package:flutter/material.dart';

import '../../models/cart_item.dart';
import '../../services/cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({
    super.key,
  });

  @override
  State<CartScreen> createState() =>
      _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService =
      CartService.instance;

  @override
  Widget build(BuildContext context) {
    final items = _cartService.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Panier 🛒',
        ),
        centerTitle: true,
      ),

      body: items.isEmpty
          ? _buildEmptyCart()
          : _buildCart(items),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 20),

            const Text(
              'Panier ou vid',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Ajoute kèk bon plat pou kòmanse commande ou.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.restaurant_menu,
              ),
              label: const Text(
                'Gade Menu',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCart(
    List<CartItem> items,
  ) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 12),
            itemBuilder: (
              context,
              index,
            ) {
              final item = items[index];

              return _buildCartItem(item);
            },
          ),
        ),

        _buildBottomSummary(),
      ],
    );
  }

  Widget _buildCartItem(
    CartItem item,
  ) {
    final plat = item.plat;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Row(
          children: [
            _buildImage(item),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    plat.nom,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '${plat.prixEffectif.toStringAsFixed(0)} HTG',
                    style: const TextStyle(
                      color: Color(0xFFE91E63),
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      _quantityButton(
                        icon: Icons.remove,
                        onPressed: () {
                          setState(() {
                            _cartService.decrease(
                              plat,
                            );
                          });
                        },
                      ),

                      Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),

                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      _quantityButton(
                        icon: Icons.add,
                        onPressed: () {
                          setState(() {
                            _cartService.add(
                              plat,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end,

              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _cartService.remove(
                        plat,
                      );
                    });
                  },

                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '${item.subtotal.toStringAsFixed(0)} HTG',

                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(
    CartItem item,
  ) {
    final imageUrl =
        item.plat.imageUrl;

    if (imageUrl == null ||
        imageUrl.isEmpty) {
      return _placeholderImage();
    }

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(12),

      child: Image.network(
        imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,

        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return _placeholderImage();
        },

        loadingBuilder: (
          context,
          child,
          loadingProgress,
        ) {
          if (loadingProgress == null) {
            return child;
          }

          return _placeholderImage(
            loading: true,
          );
        },
      ),
    );
  }

  Widget _placeholderImage({
    bool loading = false,
  }) {
    return Container(
      width: 80,
      height: 80,

      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius:
            BorderRadius.circular(12),
      ),

      child: Center(
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : Icon(
                Icons.restaurant,
                size: 30,
                color: Colors.grey.shade400,
              ),
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 34,
      height: 34,

      child: Material(
        color: const Color(0xFF008C95),
        borderRadius:
            BorderRadius.circular(10),

        child: InkWell(
          borderRadius:
              BorderRadius.circular(10),

          onTap: onPressed,

          child: Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSummary() {
    final total =
        _cartService.total;

    final totalItems =
        _cartService.totalItems;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        20,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.08),

            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),

      child: SafeArea(
        top: false,

        child: Column(
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [
                Text(
                  'Atik yo',
                  style: TextStyle(
                    color:
                        Colors.grey.shade600,
                  ),
                ),

                Text(
                  '$totalItems',
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                Text(
                  '${total.toStringAsFixed(0)} HTG',

                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFFE91E63),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton.icon(
                onPressed: () {
                  // Checkout ap vini nan pwochen etap.
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Checkout ap vini talè 🛎️',
                      ),
                    ),
                  );
                },

                icon: const Icon(
                  Icons.shopping_bag,
                ),

                label: const Text(
                  'Kontinye pou commander',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF008C95),
                  foregroundColor:
                      Colors.white,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
