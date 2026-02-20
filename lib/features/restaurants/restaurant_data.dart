import '../../models/restaurant.dart';
import '../../models/menu_item.dart';

class MockContent {
  static const banners = [
    'assets/images/banners/promo1.jpg',
    'assets/images/banners/promo2.jpg',
  ];

  static final restaurants = <Restaurant>[
    Restaurant(
      id: 'r1',
      name: 'Jollibee',
      image: 'assets/images/restaurants/jollibee.jpg',
      heroImage: 'assets/images/restaurants/jollibeehero.jpg',
      rating: 4.6,
      etaText: '25 mins',
      distanceText: '2.1 km',
      promoText: 'Free delivery • Min. ₱199',
      tags: const ['Fast Food', 'Chicken', 'Rice Meals'],
      menu: [
        MenuItem(
          id: 'm1',
          name: 'Chickenjoy 1pc w/ Rice',
          price: 99,
          image: 'assets/images/menu/chickenjoy.jpg',
          description: 'Crispylicious, juicylicious chicken.',
        ),
        MenuItem(
          id: 'm2',
          name: 'Yumburger',
          price: 50,
          image: 'assets/images/menu/yumburger.jpg',
          description: 'Classic burger with special dressing.',
        ),
        MenuItem(
          id: 'm3',
          name: 'Jolly Spaghetti',
          price: 60,
          image: 'assets/images/menu/spaghetti.jpg',
          description: 'Sweet-style spaghetti with hotdog slices.',
        ),
      ],
    ),
    Restaurant(
      id: 'r2',
      name: 'McDonald’s',
      image: 'assets/images/restaurants/mcdonalds.png',
      heroImage: 'assets/images/restaurants/mcdopromo.jpg',
      rating: 4.5,
      etaText: '22 mins',
      distanceText: '1.6 km',
      promoText: '₱49 delivery • Deals available',
      tags: const ['Fast Food', 'Burgers'],
      menu: [
        MenuItem(
          id: 'm4',
          name: 'McChicken Sandwich',
          price: 95,
          image: 'assets/images/menu/mcchicken.jpg',
          description: 'Crispy chicken patty with mayo.',
        ),
        MenuItem(
          id: 'm5',
          name: 'Fries (Medium)',
          price: 55,
          image: 'assets/images/menu/fries.jpg',
          description: 'Golden fries, perfectly salted.',
        ),
      ],
    ),
    Restaurant(
      id: 'r3',
      name: 'KFC',
      image: 'assets/images/restaurants/kfc.png',
      heroImage: 'assets/images/restaurants/kfc.jpg',
      rating: 4.4,
      etaText: '28 mins',
      distanceText: '3.0 km',
      promoText: 'Free upgrade today',
      tags: const ['Chicken', 'Fast Food'],
      menu: [
        MenuItem(
          id: 'm6',
          name: 'Original Recipe 1pc',
          price: 110,
          image: 'assets/images/menu/chickenjoy.jpg',
          description: 'Signature herbs and spices chicken.',
        ),
      ],
    ),
    Restaurant(
      id: 'r4',
      name: 'Mang Inasal',
      image: 'assets/images/restaurants/mang_inasal.png',
      heroImage: 'assets/images/restaurants/mang_inasalhero.png',
      rating: 4.3,
      etaText: '30 mins',
      distanceText: '3.4 km',
      promoText: 'Unli rice available',
      tags: const ['Chicken', 'Rice Meals'],
      menu: [
        MenuItem(
          id: 'm7',
          name: 'PM1 (Pecho)',
          price: 155,
          image: 'assets/images/menu/chickenjoy.jpg',
          description: 'Grilled chicken pecho with rice.',
        ),
      ],
    ),
  ];
}
