import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../customer/data/repositories/order_repository.dart';
import '../../../customer/data/models/order_model.dart';
import 'rider_orders_state.dart';

class RiderOrdersCubit extends Cubit<RiderOrdersState> {
  final OrderRepository orderRepository;

  RiderOrdersCubit(this.orderRepository) : super(RiderOrdersInitial());

  Future<void> fetchOrders(String riderId) async {
    emit(RiderOrdersLoading());
    try {
      final available = await orderRepository.getAvailableOrdersForDelivery();
      final myOrders = await orderRepository.getRiderOrders(riderId);
      emit(RiderOrdersLoaded(availableOrders: available, myOrders: myOrders));
    } catch (e) {
      emit(RiderOrdersError(e.toString()));
    }
  }

  Future<bool> claimOrder(String orderId, String riderId) async {
    final currentState = state;
    List<OrderModel> prevAvailable = [];
    List<OrderModel> prevMy = [];
    if (currentState is RiderOrdersLoaded) {
      prevAvailable = currentState.availableOrders;
      prevMy = currentState.myOrders;
      emit(RiderOrdersLoaded(
        availableOrders: currentState.availableOrders,
        myOrders: currentState.myOrders,
        updatingOrderId: orderId,
      ));
    }
    try {
      await orderRepository.claimOrder(orderId, riderId);
      final available = await orderRepository.getAvailableOrdersForDelivery();
      final myOrders = await orderRepository.getRiderOrders(riderId);
      emit(RiderOrdersLoaded(availableOrders: available, myOrders: myOrders));
      return true;
    } catch (e) {
      if (currentState is RiderOrdersLoaded) {
        emit(RiderOrdersLoaded(
          availableOrders: prevAvailable,
          myOrders: prevMy,
        ));
      } else {
        emit(RiderOrdersError(e.toString()));
      }
      return false;
    }
  }

  Future<bool> updateStatus(String orderId, String newStatus, String riderId) async {
    final currentState = state;
    List<OrderModel> prevAvailable = [];
    List<OrderModel> prevMy = [];
    if (currentState is RiderOrdersLoaded) {
      prevAvailable = currentState.availableOrders;
      prevMy = currentState.myOrders;
      emit(RiderOrdersLoaded(
        availableOrders: currentState.availableOrders,
        myOrders: currentState.myOrders,
        updatingOrderId: orderId,
      ));
    }
    try {
      await orderRepository.updateOrderStatus(orderId, newStatus);
      final available = await orderRepository.getAvailableOrdersForDelivery();
      final myOrders = await orderRepository.getRiderOrders(riderId);
      emit(RiderOrdersLoaded(availableOrders: available, myOrders: myOrders));
      return true;
    } catch (e) {
      if (currentState is RiderOrdersLoaded) {
        emit(RiderOrdersLoaded(
          availableOrders: prevAvailable,
          myOrders: prevMy,
        ));
      } else {
        emit(RiderOrdersError(e.toString()));
      }
      return false;
    }
  }
}
