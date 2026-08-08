import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/order_repository.dart';
import 'order_history_state.dart';

class OrderHistoryCubit extends Cubit<OrderHistoryState> {
  final OrderRepository orderRepository;

  OrderHistoryCubit(this.orderRepository) : super(OrderHistoryInitial());

  Future<void> fetchOrderHistory() async {
    emit(OrderHistoryLoading());
    try {
      final list = await orderRepository.getCustomerOrders();
      emit(OrderHistoryLoaded(list));
    } catch (e) {
      emit(OrderHistoryError(e.toString()));
    }
  }
}
