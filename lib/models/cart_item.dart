
import 'package:flutter/foundation.dart';

import 'plat.dart';

class CartItem {
  final Plat plat;
  int quantity;

  CartItem({
    required this.plat,
    this.quantity = 1,
  });

  double get subtotal {
    return plat.prixEffectif * quantity;
  }

  void increase() {
    quantity++;
  }

  void decrease() {
    if (quantity > 1) {
      quantity--;
    }
  }

  @override
  String toString() {
    return '${plat.nom} x$quantity = ${subtotal.toStringAsFixed(0)} HTG';
  }
}
