
import '../models/cart_item.dart';
import '../models/plat.dart';

class CartService {
  CartService._();

  static final CartService instance = CartService._();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItems {
    return _items.fold(
      0,
      (total, item) => total + item.quantity,
    );
  }

  double get total {
    return _items.fold(
      0,
      (total, item) => total + item.subtotal,
    );
  }

  bool contains(Plat plat) {
    return _items.any(
      (item) => item.plat.id == plat.id,
    );
  }

  CartItem? findItem(Plat plat) {
    for (final item in _items) {
      if (item.plat.id == plat.id) {
        return item;
      }
    }

    return null;
  }

  void add(Plat plat) {
    final existingItem = findItem(plat);

    if (existingItem != null) {
      existingItem.increase();
    } else {
      _items.add(
        CartItem(
          plat: plat,
          quantity: 1,
        ),
      );
    }
  }

  void decrease(Plat plat) {
    final existingItem = findItem(plat);

    if (existingItem == null) {
      return;
    }

    if (existingItem.quantity > 1) {
      existingItem.decrease();
    } else {
      _items.remove(existingItem);
    }
  }

  void remove(Plat plat) {
    _items.removeWhere(
      (item) => item.plat.id == plat.id,
    );
  }

  void clear() {
    _items.clear();
  }
}
