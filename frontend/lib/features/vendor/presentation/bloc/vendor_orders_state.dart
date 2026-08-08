import '../../../customer/data/models/order_model.dart';

abstract class VendorOrdersState {
  const VendorOrdersState();
}

class VendorOrdersInitial extends VendorOrdersState {}

class VendorOrdersLoading extends VendorOrdersState {}

class VendorOrdersLoaded extends VendorOrdersState {
  final List<OrderModel> orders;

  const VendorOrdersLoaded(this.orders);
}

class VendorOrdersError extends VendorOrdersState {
  final String message;

  const VendorOrdersError(this.message);
}
