import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/restaurant_repository.dart';
import 'restaurant_state.dart';

class RestaurantCubit extends Cubit<RestaurantState> {
  final RestaurantRepository restaurantRepository;

  RestaurantCubit(this.restaurantRepository) : super(RestaurantInitial());

  Future<void> fetchRestaurants() async {
    emit(RestaurantLoading());
    try {
      final list = await restaurantRepository.getRestaurants();
      emit(RestaurantLoaded(list));
    } catch (e) {
      emit(RestaurantError(e.toString()));
    }
  }
}
