enum RestaurantPriceRange {
  expensive,
  medium,
  cheap,
}

class RestaurantModel {
  late final String id;
  late final String name;
  late final String thumbUrl;
  late final List<String> tags;
  late final RestaurantPriceRange priceRange;
  late final double ratings;
  late final int ratingsCount;
  late final int deliveryTime;
  late final int deliveryFee;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.thumbUrl,
    required this.tags,
    required this.priceRange,
    required this.ratings,
    required this.ratingsCount,
    required this.deliveryTime,
    required this.deliveryFee,
  });

  factory RestaurantModel.fromJson({required Map<String, dynamic> json}) {
    return RestaurantModel(
      id: json['id'],
      name: json['name'],
      thumbUrl: json['thumbUrl'],
      tags: List<String>.from(json['tags']),
      priceRange: RestaurantPriceRange.values
          .firstWhere((e) => e.name == json['priceRange']),
      ratings: json['ratings'],
      ratingsCount: json['ratingsCount'],
      deliveryTime: json['deliveryTime'],
      deliveryFee: json['deliveryFee'],
    );
  }
}
