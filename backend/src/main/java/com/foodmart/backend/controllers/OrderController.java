package com.foodmart.backend.controllers;

import com.foodmart.backend.dto.OrderRequestDTO;
import com.foodmart.backend.models.Order;
import com.foodmart.backend.services.OrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.foodmart.backend.models.OrderStatus;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/orders")
@CrossOrigin(origins = "*")
public class OrderController {

    private final OrderService orderService;

    @Autowired
    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    @PostMapping
    public ResponseEntity<Order> placeOrder(@RequestBody OrderRequestDTO request) {
        try {
            Order savedOrder = orderService.createOrder(request);
            return ResponseEntity.ok(savedOrder);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @GetMapping("/customer/{customerId}")
    public ResponseEntity<List<Order>> getOrdersByCustomer(@PathVariable UUID customerId) {
        List<Order> orders = orderService.getOrdersByCustomer(customerId);
        return ResponseEntity.ok(orders);
    }

    @GetMapping("/restaurant/{restaurantId}")
    public ResponseEntity<List<Order>> getOrdersByRestaurant(@PathVariable UUID restaurantId) {
        List<Order> orders = orderService.getOrdersByRestaurant(restaurantId);
        return ResponseEntity.ok(orders);
    }

    @PutMapping("/{orderId}/status")
    public ResponseEntity<Order> updateOrderStatus(@PathVariable UUID orderId, @RequestParam OrderStatus status) {
        try {
            Order updated = orderService.updateOrderStatus(orderId, status);
            return ResponseEntity.ok(updated);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @GetMapping("/rider/{riderId}")
    public ResponseEntity<List<Order>> getOrdersByRider(@PathVariable UUID riderId) {
        List<Order> orders = orderService.getOrdersByRider(riderId);
        return ResponseEntity.ok(orders);
    }

    @PutMapping("/{orderId}/assign/{riderId}")
    public ResponseEntity<Order> assignRider(@PathVariable UUID orderId, @PathVariable UUID riderId) {
        try {
            Order updated = orderService.assignRider(orderId, riderId);
            return ResponseEntity.ok(updated);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @GetMapping("/available-for-delivery")
    public ResponseEntity<List<Order>> getAvailableOrdersForDelivery() {
        List<Order> orders = orderService.getAvailableOrdersForDelivery();
        return ResponseEntity.ok(orders);
    }

    @PutMapping("/{orderId}/claim/{riderId}")
    public ResponseEntity<?> claimOrder(@PathVariable("orderId") UUID orderId, @PathVariable("riderId") UUID riderId) {
        try {
            Order updated = orderService.claimOrder(orderId, riderId);
            return ResponseEntity.ok(updated);
        } catch (RuntimeException e) {
            System.err.println("Claim Order failed: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}
