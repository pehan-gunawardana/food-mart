package com.foodmart.backend.repositories;

import com.foodmart.backend.models.Order;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface OrderRepository extends JpaRepository<Order, UUID> {
    List<Order> findByCustomerIdOrderByCreatedAtDesc(UUID customerId);
    List<Order> findByRestaurantIdOrderByCreatedAtDesc(UUID restaurantId);
    List<Order> findByRiderIdOrderByUpdatedAtDesc(UUID riderId);
}
