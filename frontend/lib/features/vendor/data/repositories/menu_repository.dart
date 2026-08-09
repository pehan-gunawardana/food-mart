import '../../../../core/network/api_client.dart';
import '../../../customer/data/models/menu_item_model.dart';

class MenuRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<MenuItemModel>> getMenuItems(String restaurantId) async {
    try {
      final response = await _apiClient.dio.get('/restaurants/$restaurantId/menu');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => MenuItemModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch menu items: $e');
    }
  }

  Future<MenuItemModel> addMenuItem(String restaurantId, MenuItemModel item) async {
    try {
      final response = await _apiClient.dio.post(
        '/restaurants/$restaurantId/menu',
        data: item.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return MenuItemModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add menu item: $e');
    }
  }

  Future<MenuItemModel> toggleItemAvailability(String itemId, bool isAvailable) async {
    try {
      final response = await _apiClient.dio.put(
        '/menu-items/$itemId/availability',
        queryParameters: {'isAvailable': isAvailable},
      );
      if (response.statusCode == 200) {
        return MenuItemModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update item availability: $e');
    }
  }
}
