import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../customer/data/repositories/order_repository.dart';
import 'rider_orders_state.dart';

class RiderOrdersCubit extends Cubit<RiderOrdersState> {
  final OrderRepository orderRepository;
  String? _currentRiderId;

  RiderOrdersCubit(this.orderRepository) : super(RiderOrdersInitial());

  Future<void> fetchOrders(String riderId) async {
    _currentRiderId = riderId;
    emit(RiderOrdersLoading());
    try {
      final list = await orderRepository.getRiderOrders(riderId);
      emit(RiderOrdersLoaded(list));
    } catch (e) {
      emit(RiderOrdersError(e.toString()));
    }
  }

  Future<void> markAsDelivered(String orderId, [String? riderId]) async {
    final targetRiderId = riderId ?? _currentRiderId;
    if (state is RiderOrdersLoaded) {
      final currentOrders = (state as RiderOrdersLoaded).orders;
      emit(RiderOrdersLoaded(currentOrders, updatingOrderId: orderId));
    }
    try {
      await orderRepository.updateOrderStatus(orderId, 'DELIVERED');
      if (targetRiderId != null && targetRiderId.isNotEmpty) {
        final list = await orderRepository.getRiderOrders(targetRiderId);
        emit(RiderOrdersLoaded(list));
      }
    } catch (e) {
      emit(RiderOrdersError(e.toString()));
    }
  }
}
