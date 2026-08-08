import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/repositories/order_repository.dart';
import 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository orderRepository;

  OrderCubit(this.orderRepository) : super(OrderInitial());

  Future<void> placeOrder({
    required String restaurantId,
    required String deliveryAddress,
    required List<CartItemModel> items,
  }) async {
    emit(OrderLoading());
    try {
      final orderData = await orderRepository.placeOrder(
        restaurantId: restaurantId,
        deliveryAddress: deliveryAddress,
        items: items,
      );
      emit(OrderSuccess(orderData));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  void resetState() {
    emit(OrderInitial());
  }
}
