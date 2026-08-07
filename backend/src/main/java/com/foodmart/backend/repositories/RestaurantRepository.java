package com.foodmart.backend.repositories;

import com.foodmart.backend.models.Restaurant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface RestaurantRepository extends JpaRepository<Restaurant, UUID> {
    List<Restaurant> findByIsActiveTrue();
    List<Restaurant> findByOwnerId(UUID ownerId);
}
