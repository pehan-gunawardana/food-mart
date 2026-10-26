package com.foodmart.backend.services;

import com.foodmart.backend.dto.OrderRequestDTO;
import com.foodmart.backend.models.*;
import com.foodmart.backend.repositories.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
@SuppressWarnings("null")
public class OrderService {

    private final OrderRepository orderRepository;
    private final UserRepository userRepository;
    private final RestaurantRepository restaurantRepository;
    private final MenuItemRepository menuItemRepository;

    @Autowired
    public OrderService(OrderRepository orderRepository,
                        UserRepository userRepository,
                        RestaurantRepository restaurantRepository,
                        MenuItemRepository menuItemRepository) {
        this.orderRepository = orderRepository;
        this.userRepository = userRepository;
        this.restaurantRepository = restaurantRepository;
        this.menuItemRepository = menuItemRepository;
    }

    @Transactional
    public Order createOrder(OrderRequestDTO request) {
        if (request == null) {
            throw new IllegalArgumentException("Order request cannot be null");
        }

        if (request.getItems() == null || request.getItems().isEmpty()) {
            throw new IllegalArgumentException("Order must contain at least one item");
        }

        if (request.getDeliveryAddress() == null || request.getDeliveryAddress().trim().isEmpty()) {
            throw new IllegalArgumentException("Delivery address is required");
        }

        if (request.getRestaurantId() == null) {
            throw new IllegalArgumentException("Restaurant ID is required");
        }

        User customer = null;
        if (request.getCustomerId() != null) {
            customer = userRepository.findById(request.getCustomerId()).orElse(null);
        }

        if (customer == null) {
            customer = userRepository.findAll().stream()
                    .filter(u -> u.getRole() == Role.CUSTOMER)
                    .findFirst()
                    .orElseGet(() -> {
                        User mockCustomer = new User();
                        mockCustomer.setName("Mock Customer");
                        mockCustomer.setEmail("customer@foodmart.com");
                        mockCustomer.setPhone("0719999999");
                        mockCustomer.setPasswordHash("customer123");
                        mockCustomer.setRole(Role.CUSTOMER);
                        return userRepository.save(mockCustomer);
                    });
        }

        Restaurant restaurant = restaurantRepository.findById(request.getRestaurantId())
                .orElseThrow(() -> new IllegalArgumentException("Restaurant not found with ID: " + request.getRestaurantId()));

        Order order = new Order();
        order.setCustomer(customer);
        order.setRestaurant(restaurant);
        order.setDeliveryAddress(request.getDeliveryAddress().trim());
        order.setStatus(OrderStatus.PENDING);

        BigDecimal totalAmount = BigDecimal.ZERO;
        List<OrderItem> orderItems = new ArrayList<>();

        for (OrderRequestDTO.OrderItemDTO itemDto : request.getItems()) {
            if (itemDto == null) {
                throw new IllegalArgumentException("Order item cannot be null");
            }

            if (itemDto.getMenuItemId() == null) {
                throw new IllegalArgumentException("Menu item ID is required");
            }

            if (itemDto.getQuantity() == null || itemDto.getQuantity() <= 0) {
                throw new IllegalArgumentException("Item quantity must be greater than zero");
            }

            MenuItem menuItem = menuItemRepository.findById(itemDto.getMenuItemId())
                    .orElseThrow(() -> new IllegalArgumentException("MenuItem not found with ID: " + itemDto.getMenuItemId()));

            if (!menuItem.isAvailable()) {
                throw new IllegalArgumentException("Menu item is currently unavailable: " + menuItem.getName());
            }

            if (menuItem.getRestaurant() == null || !menuItem.getRestaurant().getId().equals(restaurant.getId())) {
                throw new IllegalArgumentException("Menu item does not belong to the selected restaurant: " + menuItem.getName());
            }

            BigDecimal price = menuItem.getPrice();
            if (price == null || price.compareTo(BigDecimal.ZERO) <= 0) {
                throw new IllegalArgumentException("Invalid price for menu item: " + menuItem.getName());
            }

            OrderItem orderItem = new OrderItem();
            orderItem.setOrder(order);
            orderItem.setMenuItem(menuItem);
            orderItem.setQuantity(itemDto.getQuantity());
            orderItem.setPrice(price);

            BigDecimal itemTotal = price.multiply(BigDecimal.valueOf(itemDto.getQuantity()));
            totalAmount = totalAmount.add(itemTotal);

            orderItems.add(orderItem);
        }

        order.setTotalAmount(totalAmount);
        order.setItems(orderItems);

        return orderRepository.save(order);
    }

    @Transactional(readOnly = true)
    public List<Order> getOrdersByCustomer(UUID customerId) {
        User customer = null;
        if (customerId != null) {
            customer = userRepository.findById(customerId).orElse(null);
        }

        if (customer == null) {
            customer = userRepository.findAll().stream()
                    .filter(u -> u.getRole() == Role.CUSTOMER)
                    .findFirst()
                    .orElse(null);
        }

        if (customer == null) {
            return new ArrayList<>();
        }

        return orderRepository.findByCustomerIdOrderByCreatedAtDesc(customer.getId());
    }

    @Transactional(readOnly = true)
    public List<Order> getOrdersByRestaurant(UUID restaurantId) {
        return orderRepository.findByRestaurantIdOrderByCreatedAtDesc(restaurantId);
    }

    @Transactional
    public Order updateOrderStatus(UUID orderId, OrderStatus status) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Order not found with ID: " + orderId));
        order.setStatus(status);
        return orderRepository.save(order);
    }

    @Transactional(readOnly = true)
    public List<Order> getOrdersByRider(UUID riderId) {
        return orderRepository.findByRiderIdOrderByUpdatedAtDesc(riderId);
    }

    @Transactional
    public Order assignRider(UUID orderId, UUID riderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Order not found with ID: " + orderId));
        User rider = userRepository.findById(riderId)
                .orElseThrow(() -> new IllegalArgumentException("Rider not found with ID: " + riderId));
        if (rider.getRole() != Role.RIDER) {
            throw new IllegalArgumentException("User with ID " + riderId + " is not a RIDER");
        }
        order.setRider(rider);
        order.setStatus(OrderStatus.OUT_FOR_DELIVERY);
        return orderRepository.save(order);
    }

    @Transactional(readOnly = true)
    public List<Order> getAvailableOrdersForDelivery() {
        List<Order> accepted = orderRepository.findByStatusAndRiderIsNull(OrderStatus.ACCEPTED);
        List<Order> preparing = orderRepository.findByStatusAndRiderIsNull(OrderStatus.PREPARING);
        List<Order> combined = new ArrayList<>();
        combined.addAll(accepted);
        combined.addAll(preparing);
        combined.sort((o1, o2) -> o2.getCreatedAt().compareTo(o1.getCreatedAt()));
        return combined;
    }

    @Transactional
    public Order claimOrder(UUID orderId, UUID riderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Order not found with ID: " + orderId));
        if (order.getRider() != null) {
            throw new RuntimeException("Order already claimed");
        }
        User rider = userRepository.findById(riderId)
                .orElseThrow(() -> new IllegalArgumentException("Rider not found with ID: " + riderId));
        if (rider.getRole() != Role.RIDER) {
            throw new IllegalArgumentException("User with ID " + riderId + " is not a RIDER");
        }
        order.setRider(rider);
        order.setStatus(OrderStatus.RIDER_ASSIGNED);
        return orderRepository.save(order);
    }
}
