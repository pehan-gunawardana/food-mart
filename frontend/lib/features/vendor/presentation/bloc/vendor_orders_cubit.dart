import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../customer/data/repositories/order_repository.dart';
import 'vendor_orders_state.dart';

class VendorOrdersCubit extends Cubit<VendorOrdersState> {
  final OrderRepository orderRepository;

  VendorOrdersCubit(this.orderRepository) : super(VendorOrdersInitial());

  Future<void> fetchOrders(String restaurantId) async {
    emit(VendorOrdersLoading());
    try {
      final list = await orderRepository.getRestaurantOrders(restaurantId);
      emit(VendorOrdersLoaded(list));
    } catch (e) {
      emit(VendorOrdersError(e.toString()));
    }
  }

  Future<void> updateStatus(String orderId, String newStatus, String restaurantId) async {
    try {
      await orderRepository.updateOrderStatus(orderId, newStatus);
      // Refresh restaurant orders list
      final list = await orderRepository.getRestaurantOrders(restaurantId);
      emit(VendorOrdersLoaded(list));
    } catch (e) {
      emit(VendorOrdersError(e.toString()));
    }
  }
}
