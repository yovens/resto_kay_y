
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/order_service.dart';
import '../../core/network/api_exception.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  static const Color teal = Color(0xFF087F8C);

  final OrderService _orderService = OrderService();

  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final orders = await _orderService.getOrders();

      if (!mounted) return;

      setState(() {
        _orders = orders;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Yon erè rive pandan n ap chèche kòmand yo: $e';
        _loading = false;
      });
    }
  }

  String _value(dynamic value, [String fallback = '—']) {
    if (value == null || value.toString().trim().isEmpty) {
      return fallback;
    }
    return value.toString();
  }

  String _status(dynamic value) {
    switch (_value(value, 'nouvelle').toLowerCase()) {
      case 'nouvelle':
      case 'nouveau':
      case 'new':
        return 'Nouvo kòmand';
      case 'acceptee':
      case 'acceptée':
      case 'acceptee ':
      case 'accepted':
        return 'Aksepte';
      case 'en_preparation':
      case 'preparation':
      case 'en préparation':
        return 'An preparasyon';
      case 'prete':
      case 'prête':
      case 'terminee':
      case 'terminée':
      case 'ready':
        return 'Pare';
      case 'servie':
      case 'served':
        return 'Sèvi';
      case 'annulee':
      case 'annulée':
      case 'cancelled':
        return 'Anile';
      default:
        return _value(value, 'Estati pa disponib');
    }
  }

  List<dynamic> _items(Map<String, dynamic> order) {
    final value = order['items'] ??
        order['commande_items'] ??
        order['details'];

    return value is List ? value : [];
  }

  String _itemName(dynamic item) {
    if (item is! Map) return 'Plat';

    final plat = item['plat'];

    if (plat is Map) {
      return _value(plat['nom'] ?? plat['name'], 'Plat');
    }

    return _value(
      item['nom'] ?? item['name'] ?? item['plat_nom'],
      'Plat',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          'Kòmand mwen yo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadOrders,
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafrechi',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: _loading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 180),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : _error != null
                ? ListView(
                    padding: const EdgeInsets.all(24),
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const Icon(
                        Icons.cloud_off_outlined,
                        size: 60,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Nou pa kapab chaje kòmand yo',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: FilledButton(
                          onPressed: _loadOrders,
                          child: const Text('Eseye ankò'),
                        ),
                      ),
                    ],
                  )
                : _orders.isEmpty
                    ? ListView(
                        padding: const EdgeInsets.all(24),
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 70),
                          const Icon(
                            Icons.receipt_long_outlined,
                            size: 76,
                            color: Colors.blueGrey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Poko gen kòmand',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Kòmand ou yo ap parèt isit la.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: FilledButton.icon(
                              onPressed: () => context.go('/menu'),
                              icon: const Icon(Icons.restaurant_menu),
                              label: const Text('Ale nan meni'),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          final id = order['id'] ?? order['commande_id'];
                          final status = order['statut'] ??
                              order['status'] ??
                              order['etat'];
                          final total = order['total'] ??
                              order['montant_total'] ??
                              order['total_paye'];
                          final items = _items(order);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.receipt_long,
                                        color: teal,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Kòmand #${_value(id)}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0F2F1),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _status(status),
                                      style: const TextStyle(
                                        color: teal,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Divider(height: 28),
                                  if (items.isEmpty)
                                    const Text(
                                      'Detay plat yo pa disponib nan repons API a.',
                                    )
                                  else
                                    ...items.map((item) {
                                      final quantity = item is Map
                                          ? item['quantite'] ??
                                              item['quantity'] ??
                                              1
                                          : 1;

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.restaurant,
                                              size: 18,
                                              color: Colors.blueGrey,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(_itemName(item)),
                                            ),
                                            Text('x$quantity'),
                                          ],
                                        ),
                                      );
                                    }),
                                  const Divider(height: 24),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${_value(total, '0')} HTG',
                                        style: const TextStyle(
                                          color: teal,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}