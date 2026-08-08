abstract class OrderState {
  const OrderState();
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderSuccess extends OrderState {
  final Map<String, dynamic> orderData;

  const OrderSuccess(this.orderData);
}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);
}
