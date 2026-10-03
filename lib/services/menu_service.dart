
import '../core/network/api_client.dart';
import '../models/category.dart';

class MenuService {
  final ApiClient _api = ApiClient.instance;

  Future<List<Category>> getMenu() async {
    print('MENU: ap rele API...');

    final response = await _api.get('/menu');

    print('MENU RESPONSE: $response');

    final categoriesJson =
        response['categories'] as List? ?? [];

    print(
      'MENU CATEGORIES COUNT: ${categoriesJson.length}',
    );

    final categories = categoriesJson
        .map(
          (item) => Category.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();

    for (final category in categories) {
      print(
        'CATEGORY: ${category.nom} | PLATS: ${category.plats.length}',
      );
    }

    return categories;
  }
}
