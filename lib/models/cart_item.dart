class CartItem {
  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    this.qty = 1,
  });

  final String id;
  final String name;
  final double price;
  final String image;
  int qty;

  double get lineTotal => price * qty;
}
