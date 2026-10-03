
class Plat {
  final int id;
  final String nom;
  final String? description;
  final double prix;
  final double? prixPromo;
  final bool disponible;
  final bool isPopulaire;
  final int? categoryId;
  final int totalVendu;
  final int? tempsPreparation;
  final String? image;
  final String? imageUrl;
  final double prixEffectif;

  Plat({
    required this.id,
    required this.nom,
    this.description,
    required this.prix,
    this.prixPromo,
    required this.disponible,
    required this.isPopulaire,
    this.categoryId,
    required this.totalVendu,
    this.tempsPreparation,
    this.image,
    this.imageUrl,
    required this.prixEffectif,
  });

  factory Plat.fromJson(
    Map<String, dynamic> json,
  ) {
    return Plat(
      id: int.parse(
        json['id'].toString(),
      ),

      nom: json['nom']?.toString() ?? '',

      description:
          json['description']?.toString(),

      prix: double.tryParse(
            json['prix'].toString(),
          ) ??
          0,

      prixPromo:
          json['prix_promo'] == null
              ? null
              : double.tryParse(
                  json['prix_promo'].toString(),
                ),

      disponible:
          json['disponible'] == true ||
          json['disponible'].toString() == '1',

      isPopulaire:
          json['is_populaire'] == true ||
          json['is_populaire'].toString() == '1',

      categoryId:
          json['category_id'] == null
              ? null
              : int.tryParse(
                  json['category_id'].toString(),
                ),

      totalVendu: int.tryParse(
            json['total_vendu'].toString(),
          ) ??
          0,

      tempsPreparation:
          json['temps_preparation'] == null
              ? null
              : int.tryParse(
                  json['temps_preparation']
                      .toString(),
                ),

      image: json['image']?.toString(),

      imageUrl:
          json['image_url']?.toString(),

      prixEffectif:
          double.tryParse(
                json['prix_effectif']
                    .toString(),
              ) ??
              double.tryParse(
                json['prix_promo']
                    .toString(),
              ) ??
              double.tryParse(
                json['prix'].toString(),
              ) ??
              0,
    );
  }
}
