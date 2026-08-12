package com.foodmart.backend.services;

import com.foodmart.backend.models.MenuItem;
import com.foodmart.backend.models.Restaurant;
import com.foodmart.backend.repositories.MenuItemRepository;
import com.foodmart.backend.repositories.RestaurantRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
@SuppressWarnings("null")
public class MenuItemService {

    private final MenuItemRepository menuItemRepository;
    private final RestaurantRepository restaurantRepository;

    @Autowired
    public MenuItemService(MenuItemRepository menuItemRepository, RestaurantRepository restaurantRepository) {
        this.menuItemRepository = menuItemRepository;
        this.restaurantRepository = restaurantRepository;
    }

    public MenuItem addMenuItem(UUID restaurantId, MenuItem menuItem) {
        Restaurant restaurant = restaurantRepository.findById(restaurantId)
                .orElseThrow(() -> new IllegalArgumentException("Restaurant with ID " + restaurantId + " not found"));
        
        menuItem.setRestaurant(restaurant);
        return menuItemRepository.save(menuItem);
    }

    public List<MenuItem> listMenuItemsByRestaurant(UUID restaurantId) {
        // We could also verify if the restaurant exists, but we can directly return list
        return menuItemRepository.findByRestaurantId(restaurantId);
    }

    public MenuItem toggleItemAvailability(UUID itemId, boolean isAvailable) {
        MenuItem menuItem = menuItemRepository.findById(itemId)
                .orElseThrow(() -> new IllegalArgumentException("MenuItem with ID " + itemId + " not found"));
        menuItem.setAvailable(isAvailable);
        return menuItemRepository.save(menuItem);
    }
}
