import '../../../../core/network/api_client.dart';
import '../models/restaurant_model.dart';

class RestaurantRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<RestaurantModel>> getRestaurants() async {
    try {
      final response = await _apiClient.dio.get('/restaurants');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => RestaurantModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch restaurants from API: $e');
    }
  }
}
