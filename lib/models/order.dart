class Order {
  Order({
    required this.orderId,
    required this.restaurantName,
    required this.total,
    required this.createdAtIso,
    required this.status,
  });

  final String orderId;
  final String restaurantName;
  final double total;
  final String createdAtIso;
  final String status;
}
