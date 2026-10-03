
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/cart_item.dart';

class OrderService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<Map<String, dynamic>> createOrder({
    required int tableId,
    required List<CartItem> items,
    String? note,
  }) async {
    if (items.isEmpty) {
      throw const ApiException(
        'Panier la vid. Tanpri ajoute omwen yon plat.',
      );
    }

    final payload = {
      'restaurant_table_id': tableId,
      'note': note?.trim().isEmpty == true
          ? null
          : note?.trim(),
      'items': items.map((item) {
        return {
          'plat_id': item.plat.id,
          'quantite': item.quantity,
        };
      }).toList(),
    };

    final response = await _apiClient.post(
      '/commandes',
      body: payload,
    );

    if (response is Map<String, dynamic>) {
      return response;
    }

    throw const ApiException(
      'Réponse serveur a pa valab.',
    );
  }
}
