import '../../../../core/network/api_client.dart';
import '../../data/models/cart_item_model.dart';
import '../models/order_model.dart';

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

  Future<List<OrderModel>> getCustomerOrders() async {
    try {
      final response = await _apiClient.dio.get('/orders/customer/123e4567-e89b-12d3-a456-426614174000');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => OrderModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Server returned status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch customer orders: $e');
    }
  }

  Future<List<OrderModel>> getRestaurantOrders(String restaurantId) async {
    try {
      final response = await _apiClient.dio.get('/orders/restaurant/$restaurantId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => OrderModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Server returned status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch restaurant orders: $e');
    }
  }

  Future<OrderModel> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await _apiClient.dio.put(
        '/orders/$orderId/status',
        queryParameters: {'status': status},
      );
      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Server returned status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  Future<List<OrderModel>> getRiderOrders(String riderId) async {
    try {
      final response = await _apiClient.dio.get('/orders/rider/$riderId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => OrderModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Server returned status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch rider orders: $e');
    }
  }

  Future<OrderModel> assignRider(String orderId, String riderId) async {
    try {
      final response = await _apiClient.dio.put('/orders/$orderId/assign/$riderId');
      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Server returned status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to assign rider: $e');
    }
  }
}
