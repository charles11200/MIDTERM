import '../models/cart_item.dart';

class CartStore {
  static final CartStore instance = CartStore._();
  CartStore._();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get count => _items.fold(0, (s, e) => s + e.qty);

  double get total => _items.fold(0, (s, e) => s + e.lineTotal);

  void add(CartItem item) {
    final idx = _items.indexWhere((e) => e.id == item.id);
    if (idx >= 0) {
      _items[idx].qty += 1;
    } else {
      _items.add(item);
    }
  }

  void decrease(String id) {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    _items[idx].qty -= 1;
    if (_items[idx].qty <= 0) {
      _items.removeAt(idx);
    }
  }

  void remove(String id) {
    _items.removeWhere((e) => e.id == id);
  }

  void clear() => _items.clear();
}
