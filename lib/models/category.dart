
import 'plat.dart';

class Category {
  final int id;
  final String nom;
  final String? description;
  final List<Plat> plats;

  Category({
    required this.id,
    required this.nom,
    this.description,
    required this.plats,
  });

  factory Category.fromJson(
    Map<String, dynamic> json,
  ) {
    final platsJson =
        json['plats'] as List? ?? [];

    return Category(
      id: int.parse(
        json['id'].toString(),
      ),

      nom: json['nom']?.toString() ?? '',

      description:
          json['description']?.toString(),

      plats: platsJson
          .map(
            (item) => Plat.fromJson(
              Map<String, dynamic>.from(
                item,
              ),
            ),
          )
          .toList(),
    );
  }
}
