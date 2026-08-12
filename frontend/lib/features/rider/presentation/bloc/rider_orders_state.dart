import '../../../customer/data/models/order_model.dart';

abstract class RiderOrdersState {
  const RiderOrdersState();
}

class RiderOrdersInitial extends RiderOrdersState {}

class RiderOrdersLoading extends RiderOrdersState {}

class RiderOrdersLoaded extends RiderOrdersState {
  final List<OrderModel> orders;
  final String? updatingOrderId;

  const RiderOrdersLoaded(this.orders, {this.updatingOrderId});
}

class RiderOrdersError extends RiderOrdersState {
  final String message;

  const RiderOrdersError(this.message);
}
