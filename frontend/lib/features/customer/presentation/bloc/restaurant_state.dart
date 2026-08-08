import '../../data/models/restaurant_model.dart';

abstract class RestaurantState {
  const RestaurantState();
}

class RestaurantInitial extends RestaurantState {}

class RestaurantLoading extends RestaurantState {}

class RestaurantLoaded extends RestaurantState {
  final List<RestaurantModel> restaurants;

  const RestaurantLoaded(this.restaurants);
}

class RestaurantError extends RestaurantState {
  final String message;

  const RestaurantError(this.message);
}
