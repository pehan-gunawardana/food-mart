import '../../../auth/data/models/user_model.dart';
import 'menu_item_model.dart';

class OrderModel {
  final String id;
  final double totalAmount;
  final String status;
  final String deliveryAddress;
  final DateTime createdAt;
  final List<OrderItemModel> items;
  final UserModel? rider;

  OrderModel({
    required this.id,
    required this.totalAmount,
    required this.status,
    required this.deliveryAddress,
    required this.createdAt,
    required this.items,
    this.rider,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsList = json['items'] as List<dynamic>? ?? [];
    return OrderModel(
      id: json['id'] as String? ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'PENDING',
      deliveryAddress: json['deliveryAddress'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      items: itemsList
          .map((itemJson) => OrderItemModel.fromJson(itemJson as Map<String, dynamic>))
          .toList(),
      rider: json['rider'] != null
          ? UserModel.fromJson(json['rider'] as Map<String, dynamic>)
          : null,
    );
  }
}

class OrderItemModel {
  final String id;
  final MenuItemModel menuItem;
  final int quantity;
  final double price;

  OrderItemModel({
    required this.id,
    required this.menuItem,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String? ?? '',
      menuItem: json['menuItem'] != null
          ? MenuItemModel.fromJson(json['menuItem'] as Map<String, dynamic>)
          : MenuItemModel(
              id: '',
              name: 'Unknown Item',
              description: '',
              price: 0.0,
              imageUrl: '',
              isAvailable: false,
            ),
      quantity: json['quantity'] as int? ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
