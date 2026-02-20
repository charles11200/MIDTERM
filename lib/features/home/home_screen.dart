import 'package:flutter/cupertino.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/safe_image.dart';
import '../restaurants/restaurant_data.dart';
import '../restaurants/restaurant_menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String query = '';
  String filter = 'All';

  final filters = const ['All', 'Fast Food', 'Chicken', 'Burgers', 'Rice Meals', 'Deals'];

  @override
  Widget build(BuildContext context) {
    final list = MockContent.restaurants.where((r) {
      final qOk = query.isEmpty || r.name.toLowerCase().contains(query.toLowerCase());
      final fOk = filter == 'All' || r.tags.contains(filter) || (filter == 'Deals');
      return qOk && fOk;
    }).toList();

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: Column(
          children: [
            _Header(
              onSearch: (v) => setState(() => query = v),
              filters: filters,
              selected: filter,
              onFilter: (f) => setState(() => filter = f),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 12, bottom: 16),
                children: [
                  // promo banners
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: MockContent.banners.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        return SafeAssetImage(
                          path: MockContent.banners[i],
                          width: 260,
                          height: 140,
                          radius: 18,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Restaurants', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                        Text('See all', style: TextStyle(color: CupertinoColors.systemGrey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  ...list.map((r) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: _RestaurantCard(
                      image: r.image,
                      name: r.name,
                      rating: r.rating,
                      distance: r.distanceText,
                      eta: r.etaText,
                      promo: r.promoText,
                      onTap: () => Navigator.of(context).push(
                        CupertinoPageRoute(builder: (_) => RestaurantMenuScreen(restaurant: r)),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.onSearch,
    required this.filters,
    required this.selected,
    required this.onFilter,
  });

  final ValueChanged<String> onSearch;
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onFilter;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.tealHeader,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.location_solid, color: CupertinoColors.white, size: 18),
              const SizedBox(width: 6),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DELIVER TO', style: TextStyle(color: CupertinoColors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                    SizedBox(height: 2),
                    Text('Enter an address', style: TextStyle(color: CupertinoColors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {},
                child: const Icon(CupertinoIcons.bell, color: CupertinoColors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: CupertinoColors.white, borderRadius: BorderRadius.circular(12)),
            child: CupertinoSearchTextField(
              placeholder: 'Would you like to eat something?',
              onChanged: onSearch,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final f = filters[i];
                final active = f == selected;
                return CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  color: active ? CupertinoColors.white : const Color(0x30FFFFFF),
                  borderRadius: BorderRadius.circular(18),
                  onPressed: () => onFilter(f),
                  child: Row(
                    children: [
                      Text(
                        f,
                        style: TextStyle(
                          color: active ? CupertinoColors.black : CupertinoColors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (f != 'All') ...[
                        const SizedBox(width: 6),
                        Icon(CupertinoIcons.chevron_down, size: 14, color: active ? CupertinoColors.black : CupertinoColors.white),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({
    required this.image,
    required this.name,
    required this.rating,
    required this.distance,
    required this.eta,
    required this.promo,
    required this.onTap,
  });

  final String image;
  final String name;
  final double rating;
  final String distance;
  final String eta;
  final String promo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            SafeAssetImage(path: image, width: 72, height: 72, radius: 14),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(CupertinoIcons.star_fill, size: 14, color: Color(0xFFFFB300)),
                    const SizedBox(width: 4),
                    Text(rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Text('$distance • $eta', style: const TextStyle(color: CupertinoColors.systemGrey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(promo, style: const TextStyle(color: AppColors.greenText, fontSize: 12, fontWeight: FontWeight.w800)),
                ),
              ]),
            ),
            const Icon(CupertinoIcons.chevron_right, color: CupertinoColors.systemGrey),
          ],
        ),
      ),
    );
  }
}
