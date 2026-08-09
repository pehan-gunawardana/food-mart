import '../../../customer/data/models/menu_item_model.dart';

abstract class VendorMenuState {
  const VendorMenuState();
}

class VendorMenuInitial extends VendorMenuState {}

class VendorMenuLoading extends VendorMenuState {}

class VendorMenuLoaded extends VendorMenuState {
  final List<MenuItemModel> items;
  final String? togglingItemId;
  final bool isAdding;

  const VendorMenuLoaded(
    this.items, {
    this.togglingItemId,
    this.isAdding = false,
  });
}

class VendorMenuError extends VendorMenuState {
  final String message;

  const VendorMenuError(this.message);
}
