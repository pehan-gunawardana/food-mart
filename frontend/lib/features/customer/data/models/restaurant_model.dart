class RestaurantModel {
  final String id;
  final String name;
  final String description;
  final String address;
  final String contactNumber;
  final bool isActive;
  final String coverImageUrl;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.contactNumber,
    required this.isActive,
    required this.coverImageUrl,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      address: json['address'] as String? ?? '',
      contactNumber: json['contactNumber'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? false,
      coverImageUrl: json['coverImageUrl'] as String? ?? '',
    );
  }
}
