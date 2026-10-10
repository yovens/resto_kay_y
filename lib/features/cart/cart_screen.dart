
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../models/cart_item.dart';
import '../../services/cart_service.dart';
import '../../services/order_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService.instance;
  final OrderService _orderService = OrderService();
  final TextEditingController _noteController =
      TextEditingController();

  int? _selectedTableId;
  bool _submitting = false;
  String? _error;

  static const Color _teal = Color(0xFF00897B);
  static const Color _pink = Color(0xFFE91E63);
  static const Color _yellow = Color(0xFFFFC928);

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _confirmOrder() async {
    if (_submitting) return;

    if (!ApiClient.instance.isAuthenticated) {
      setState(() {
        _error =
            'Ou dwe konekte sou kont ou anvan ou pase commande.';
      });
      return;
    }

    if (_cartService.items.isEmpty) {
      setState(() {
        _error = 'Panier la vid.';
      });
      return;
    }

    if (_selectedTableId == null) {
      setState(() {
        _error = 'Tanpri chwazi nimewo tab ou.';
      });
      return;
    }

    final items = List<CartItem>.from(_cartService.items);
    final tableId = _selectedTableId!;
    final note = _noteController.text.trim();

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final result = await _orderService.createOrder(
        tableId: tableId,
        items: items,
        note: note.isEmpty ? null : note,
      );

      if (!mounted) return;

      final commande = result['commande'];
      final orderId = commande is Map
          ? commande['id']?.toString()
          : null;
      final total = commande is Map
          ? commande['total']?.toString()
          : null;

      _cartService.clear();

      setState(() {
        _submitting = false;
      });

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: _teal.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: _teal,
                    size: 54,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Mèsi anpil! 🎉',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Commande ou a anrejistre avèk siksè.',
                  textAlign: TextAlign.center,
                ),
                if (orderId != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Commande #$orderId',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _teal,
                      fontSize: 17,
                    ),
                  ),
                ],
                if (total != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Total: ${_formatMoney(num.tryParse(total) ?? 0)} HTG',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                const Text(
                  'Kizin nan ap resevwa commande ou a.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _teal,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Kontinye'),
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _submitting = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _submitting = false;
        _error =
            'Yon erè rive. Tanpri verifye koneksyon ou epi eseye ankò.';
      });

      debugPrint('CREATE ORDER ERROR: $e');
    }
  }

  String _formatMoney(num amount) {
    return amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final items = _cartService.items;
    final total = _cartService.total;
    final totalItems = _cartService.totalItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: _teal,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Panier mwen 🛒',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: items.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildHeader(totalItems),
                      const SizedBox(height: 16),
                      ...items.map(_buildCartItem),
                      const SizedBox(height: 20),
                      _buildTableSelector(),
                      const SizedBox(height: 16),
                      _buildNoteField(),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        _buildError(),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                _buildCheckoutBar(totalItems, total),
              ],
            ),
    );
  }

  Widget _buildHeader(int totalItems) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Sa w chwazi yo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: _yellow.withValues(alpha: 0.30),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$totalItems atik',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartItem item) {
    final plat = item.plat;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 88,
              height: 88,
              child: plat.imageUrl != null &&
                      plat.imageUrl!.isNotEmpty
                  ? Image.network(
                      plat.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _buildImagePlaceholder(),
                    )
                  : _buildImagePlaceholder(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plat.nom,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${_formatMoney(plat.prixEffectif)} HTG / inite',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_formatMoney(item.subtotal)} HTG',
                  style: const TextStyle(
                    color: _teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _quantityButton(
                    icon: Icons.remove,
                    onPressed: () {
                      setState(() {
                        _cartService.decrease(plat);
                        _error = null;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  _quantityButton(
                    icon: Icons.add,
                    onPressed: () {
                      setState(() {
                        _cartService.add(plat);
                        _error = null;
                      });
                    },
                  ),
                ],
              ),
              IconButton(
                tooltip: 'Retire plat la',
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  setState(() {
                    _cartService.remove(plat);
                    _error = null;
                  });
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: _pink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 30,
      height: 30,
      child: Material(
        color: _teal.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: onPressed,
          child: Icon(
            icon,
            size: 17,
            color: _teal,
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFFE8F2F0),
      child: const Icon(
        Icons.restaurant,
        size: 34,
        color: _teal,
      ),
    );
  }

  Widget _buildTableSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.table_restaurant, color: _teal),
              SizedBox(width: 8),
              Text(
                'Ki tab ou ye?',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _selectedTableId,
            decoration: InputDecoration(
              hintText: 'Chwazi nimewo tab la',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: 1,
                child: Text('Tab 1'),
              ),
              DropdownMenuItem(
                value: 2,
                child: Text('Tab 2'),
              ),
              DropdownMenuItem(
                value: 3,
                child: Text('Tab 3'),
              ),
            ],
            onChanged: _submitting
                ? null
                : (value) {
                    setState(() {
                      _selectedTableId = value;
                      _error = null;
                    });
                  },
          ),
          const SizedBox(height: 8),
          const Text(
            'Verifye nimewo tab ou anvan ou konfime.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.edit_note, color: _teal),
              SizedBox(width: 8),
              Text(
                'Nòt pou kizin nan',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 6),
              Text(
                '(opsyonèl)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            enabled: !_submitting,
            maxLines: 3,
            maxLength: 1000,
            decoration: InputDecoration(
              hintText:
                  'Egzanp: Pa mete pikliz, pa mete piman...',
              filled: true,
              fillColor: const Color(0xFFF7F8FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _pink.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _pink.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: _pink,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(
                color: _pink,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar(int totalItems, double total) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total commande',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
              Text(
                '${_formatMoney(total)} HTG',
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: _teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Total plat yo; se Laravel ki kalkile pri final la.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed:
                  _submitting ? null : _confirmOrder,
              style: FilledButton.styleFrom(
                backgroundColor: _teal,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    _teal.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(
                _submitting
                    ? 'Ap voye commande a...'
                    : 'Konfime commande ($totalItems atik)',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: _yellow.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 54,
                color: _teal,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Panier ou vid!',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Dekouvri bon manje yo nan meni Resto Kay-Y.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
             onPressed: () => context.go('/menu'),
              style: FilledButton.styleFrom(
                backgroundColor: _teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
              ),
              icon: const Icon(Icons.restaurant_menu),
              label: const Text('Retounen nan meni'),
            ),
          ],
        ),
      ),
    );
  }
}