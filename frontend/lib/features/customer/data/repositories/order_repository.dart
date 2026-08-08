import '../../../../core/network/api_client.dart';
import '../../data/models/cart_item_model.dart';

class OrderRepository {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> placeOrder({
    required String restaurantId,
    required String deliveryAddress,
    required List<CartItemModel> items,
  }) async {
    try {
      final List<Map<String, dynamic>> itemsPayload = items.map((cartItem) {
        return {
          'menuItemId': cartItem.item.id,
          'quantity': cartItem.quantity,
          'price': cartItem.item.price,
        };
      }).toList();

      final payload = {
        'customerId': '123e4567-e89b-12d3-a456-426614174000', // Mock UUID matching DatabaseSeeder User
        'restaurantId': restaurantId,
        'deliveryAddress': deliveryAddress,
        'items': itemsPayload,
      };

      print('Order Payload: $payload');
      final response = await _apiClient.dio.post('/orders', data: payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to place order: $e');
    }
  }
}
