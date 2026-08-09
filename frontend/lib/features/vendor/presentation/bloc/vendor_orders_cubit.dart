import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../customer/data/repositories/order_repository.dart';
import 'vendor_orders_state.dart';

class VendorOrdersCubit extends Cubit<VendorOrdersState> {
  final OrderRepository orderRepository;
  String? _currentRestaurantId;

  VendorOrdersCubit(this.orderRepository) : super(VendorOrdersInitial());

  Future<void> fetchOrders(String restaurantId) async {
    _currentRestaurantId = restaurantId;
    emit(VendorOrdersLoading());
    try {
      final list = await orderRepository.getRestaurantOrders(restaurantId);
      emit(VendorOrdersLoaded(list));
    } catch (e) {
      emit(VendorOrdersError(e.toString()));
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus, [String? restaurantId]) async {
    final targetRestaurantId = restaurantId ?? _currentRestaurantId;
    if (state is VendorOrdersLoaded) {
      final currentOrders = (state as VendorOrdersLoaded).orders;
      emit(VendorOrdersLoaded(currentOrders, updatingOrderId: orderId));
    }
    try {
      await orderRepository.updateOrderStatus(orderId, newStatus);
      if (targetRestaurantId != null && targetRestaurantId.isNotEmpty) {
        final list = await orderRepository.getRestaurantOrders(targetRestaurantId);
        emit(VendorOrdersLoaded(list));
      }
    } catch (e) {
      emit(VendorOrdersError(e.toString()));
    }
  }

  Future<void> updateStatus(String orderId, String newStatus, String restaurantId) async {
    await updateOrderStatus(orderId, newStatus, restaurantId);
  }
}
