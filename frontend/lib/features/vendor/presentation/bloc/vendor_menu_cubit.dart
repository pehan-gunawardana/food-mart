import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../customer/data/models/menu_item_model.dart';
import '../../data/repositories/menu_repository.dart';
import 'vendor_menu_state.dart';

class VendorMenuCubit extends Cubit<VendorMenuState> {
  final MenuRepository menuRepository;
  String? _currentRestaurantId;

  VendorMenuCubit(this.menuRepository) : super(VendorMenuInitial());

  Future<void> fetchMenuItems(String restaurantId) async {
    _currentRestaurantId = restaurantId;
    emit(VendorMenuLoading());
    try {
      final items = await menuRepository.getMenuItems(restaurantId);
      emit(VendorMenuLoaded(items));
    } catch (e) {
      emit(VendorMenuError(e.toString()));
    }
  }

  Future<bool> addMenuItem(String restaurantId, MenuItemModel item) async {
    final targetId = restaurantId.isNotEmpty ? restaurantId : (_currentRestaurantId ?? '');
    if (state is VendorMenuLoaded) {
      final currentItems = (state as VendorMenuLoaded).items;
      emit(VendorMenuLoaded(currentItems, isAdding: true));
    }
    try {
      await menuRepository.addMenuItem(targetId, item);
      final updatedList = await menuRepository.getMenuItems(targetId);
      emit(VendorMenuLoaded(updatedList));
      return true;
    } catch (e) {
      emit(VendorMenuError(e.toString()));
      return false;
    }
  }

  Future<void> toggleItemAvailability(String restaurantId, String itemId, bool isAvailable) async {
    final targetId = restaurantId.isNotEmpty ? restaurantId : (_currentRestaurantId ?? '');
    if (state is VendorMenuLoaded) {
      final currentItems = (state as VendorMenuLoaded).items;
      // Optimistically update UI item state or show toggling item ID
      final updatedOptimistic = currentItems.map((item) {
        if (item.id == itemId) {
          return item.copyWith(isAvailable: isAvailable);
        }
        return item;
      }).toList();
      emit(VendorMenuLoaded(updatedOptimistic, togglingItemId: itemId));
    }
    try {
      final updatedItem = await menuRepository.toggleItemAvailability(itemId, isAvailable);
      if (state is VendorMenuLoaded) {
        final currentItems = (state as VendorMenuLoaded).items;
        final updatedList = currentItems.map((item) {
          if (item.id == itemId) {
            return updatedItem;
          }
          return item;
        }).toList();
        emit(VendorMenuLoaded(updatedList));
      } else if (targetId.isNotEmpty) {
        final list = await menuRepository.getMenuItems(targetId);
        emit(VendorMenuLoaded(list));
      }
    } catch (e) {
      // Re-fetch list to restore true state if API call failed
      if (targetId.isNotEmpty) {
        try {
          final list = await menuRepository.getMenuItems(targetId);
          emit(VendorMenuLoaded(list));
        } catch (_) {
          emit(VendorMenuError(e.toString()));
        }
      } else {
        emit(VendorMenuError(e.toString()));
      }
    }
  }
}
