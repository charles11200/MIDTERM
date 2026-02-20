import '../models/order.dart';

class OrderStore {
  static final OrderStore instance = OrderStore._();
  OrderStore._();

  final List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);

  void addOrder(Order o) => _orders.insert(0, o);
}
