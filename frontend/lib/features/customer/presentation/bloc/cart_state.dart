import '../../data/models/cart_item_model.dart';

class CartState {
  final List<CartItemModel> items;

  CartState({
    this.items = const [],
  });

  double get totalPrice => items.fold(0.0, (sum, element) => sum + element.totalPrice);
  int get totalItems => items.fold(0, (sum, element) => sum + element.quantity);

  CartState copyWith({
    List<CartItemModel>? items,
  }) {
    return CartState(
      items: items ?? this.items,
    );
  }
}
