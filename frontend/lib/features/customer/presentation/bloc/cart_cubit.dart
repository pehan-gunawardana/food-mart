import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/menu_item_model.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState());

  void addItem(MenuItemModel item) {
    final existingIndex = state.items.indexWhere((element) => element.item.id == item.id);
    final updatedItems = List<CartItemModel>.from(state.items);

    if (existingIndex >= 0) {
      final existingItem = updatedItems[existingIndex];
      updatedItems[existingIndex] = existingItem.copyWith(quantity: existingItem.quantity + 1);
    } else {
      updatedItems.add(CartItemModel(item: item, quantity: 1));
    }

    emit(state.copyWith(items: updatedItems));
  }

  void removeItem(MenuItemModel item) {
    final existingIndex = state.items.indexWhere((element) => element.item.id == item.id);
    if (existingIndex < 0) return;

    final updatedItems = List<CartItemModel>.from(state.items);
    final existingItem = updatedItems[existingIndex];

    if (existingItem.quantity > 1) {
      updatedItems[existingIndex] = existingItem.copyWith(quantity: existingItem.quantity - 1);
    } else {
      updatedItems.removeAt(existingIndex);
    }

    emit(state.copyWith(items: updatedItems));
  }

  void clearCart() {
    emit(CartState(items: const []));
  }
}
