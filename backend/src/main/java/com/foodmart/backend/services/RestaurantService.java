package com.foodmart.backend.services;

import com.foodmart.backend.models.Restaurant;
import com.foodmart.backend.models.User;
import com.foodmart.backend.repositories.RestaurantRepository;
import com.foodmart.backend.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class RestaurantService {

    private final RestaurantRepository restaurantRepository;
    private final UserRepository userRepository;

    @Autowired
    public RestaurantService(RestaurantRepository restaurantRepository, UserRepository userRepository) {
        this.restaurantRepository = restaurantRepository;
        this.userRepository = userRepository;
    }

    public Restaurant registerRestaurant(Restaurant restaurant) {
        if (restaurant.getOwner() == null || restaurant.getOwner().getId() == null) {
            throw new IllegalArgumentException("Restaurant owner must be specified with a valid ID");
        }
        
        UUID ownerId = restaurant.getOwner().getId();
        User owner = userRepository.findById(ownerId)
                .orElseThrow(() -> new IllegalArgumentException("Owner with ID " + ownerId + " not found"));
        
        restaurant.setOwner(owner);
        return restaurantRepository.save(restaurant);
    }

    public List<Restaurant> listActiveRestaurants() {
        return restaurantRepository.findByIsActiveTrue();
    }

    public List<Restaurant> getRestaurantsByOwner(UUID ownerId) {
        return restaurantRepository.findByOwnerId(ownerId);
    }

    public Optional<Restaurant> getRestaurantById(UUID id) {
        return restaurantRepository.findById(id);
    }
}
