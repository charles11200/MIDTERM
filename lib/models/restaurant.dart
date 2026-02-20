import 'menu_item.dart';

class Restaurant {
  Restaurant({
    required this.id,
    required this.name,
    required this.image,
    required this.heroImage,
    required this.rating,
    required this.etaText,
    required this.distanceText,
    required this.promoText,
    required this.tags,
    required this.menu,
  });

  final String id;
  final String name;
  final String image;      // thumbnail for list
  final String heroImage;  // big banner for restaurant page

  final double rating;
  final String etaText;
  final String distanceText;
  final String promoText;
  final List<String> tags;

  final List<MenuItem> menu;
}
