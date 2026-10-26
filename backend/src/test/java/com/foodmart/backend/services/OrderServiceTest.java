package com.foodmart.backend.services;

import com.foodmart.backend.dto.OrderRequestDTO;
import com.foodmart.backend.models.*;
import com.foodmart.backend.repositories.MenuItemRepository;
import com.foodmart.backend.repositories.OrderRepository;
import com.foodmart.backend.repositories.RestaurantRepository;
import com.foodmart.backend.repositories.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class OrderServiceTest {

    @Mock
    private OrderRepository orderRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private RestaurantRepository restaurantRepository;

    @Mock
    private MenuItemRepository menuItemRepository;

    @InjectMocks
    private OrderService orderService;

    private UUID restaurantId;
    private UUID menuItemId1;
    private UUID menuItemId2;
    private UUID customerId;

    private Restaurant restaurant;
    private MenuItem menuItem1;
    private MenuItem menuItem2;
    private User customer;

    @BeforeEach
    void setUp() {
        restaurantId = UUID.randomUUID();
        menuItemId1 = UUID.randomUUID();
        menuItemId2 = UUID.randomUUID();
        customerId = UUID.randomUUID();

        customer = new User();
        customer.setId(customerId);
        customer.setName("Pehan Test");
        customer.setEmail("customer@test.com");
        customer.setRole(Role.CUSTOMER);

        restaurant = new Restaurant();
        restaurant.setId(restaurantId);
        restaurant.setName("Tangalle Seafoods");
        restaurant.setActive(true);

        menuItem1 = new MenuItem();
        menuItem1.setId(menuItemId1);
        menuItem1.setName("Jumbo Prawns");
        menuItem1.setPrice(new BigDecimal("2800.00"));
        menuItem1.setAvailable(true);
        menuItem1.setRestaurant(restaurant);

        menuItem2 = new MenuItem();
        menuItem2.setId(menuItemId2);
        menuItem2.setName("Fried Rice");
        menuItem2.setPrice(new BigDecimal("950.00"));
        menuItem2.setAvailable(true);
        menuItem2.setRestaurant(restaurant);
    }

    private OrderRequestDTO createBaseValidRequest() {
        OrderRequestDTO request = new OrderRequestDTO();
        request.setCustomerId(customerId);
        request.setRestaurantId(restaurantId);
        request.setDeliveryAddress("No 15, Beach Road, Tangalle");

        OrderRequestDTO.OrderItemDTO itemDto = new OrderRequestDTO.OrderItemDTO();
        itemDto.setMenuItemId(menuItemId1);
        itemDto.setQuantity(2);
        itemDto.setPrice(new BigDecimal("2800.00"));

        List<OrderRequestDTO.OrderItemDTO> items = new ArrayList<>();
        items.add(itemDto);
        request.setItems(items);

        return request;
    }

    @Test
    @DisplayName("Should ignore client-submitted fake price and enforce authoritative database price")
    void shouldIgnoreClientSubmittedPriceAndUseDatabasePrice() {
        OrderRequestDTO request = createBaseValidRequest();
        // Client tries to exploit by submitting 0.01 instead of 2800.00
        request.getItems().get(0).setPrice(new BigDecimal("0.01"));

        when(userRepository.findById(customerId)).thenReturn(Optional.of(customer));
        when(restaurantRepository.findById(restaurantId)).thenReturn(Optional.of(restaurant));
        when(menuItemRepository.findById(menuItemId1)).thenReturn(Optional.of(menuItem1));
        when(orderRepository.save(any(Order.class))).thenAnswer(invocation -> invocation.getArgument(0));

        Order order = orderService.createOrder(request);

        assertNotNull(order);
        // Authoritative price is 2800.00, quantity is 2 -> Total must be 5600.00, NOT
        // 0.02
        assertEquals(new BigDecimal("5600.00"), order.getTotalAmount());
        assertEquals(new BigDecimal("2800.00"), order.getItems().get(0).getPrice());
        assertEquals(OrderStatus.PENDING, order.getStatus());
        verify(orderRepository, times(1)).save(any(Order.class));
    }

    @Test
    @DisplayName("Should correctly calculate order total for multiple items and multiple quantities")
    void shouldCalculateTotalCorrectlyForMultipleItemsAndQuantities() {
        OrderRequestDTO request = createBaseValidRequest();

        // Item 1: 2800.00 x 2 = 5600.00
        request.getItems().get(0).setQuantity(2);

        // Item 2: 950.00 x 3 = 2850.00
        OrderRequestDTO.OrderItemDTO item2Dto = new OrderRequestDTO.OrderItemDTO();
        item2Dto.setMenuItemId(menuItemId2);
        item2Dto.setQuantity(3);
        item2Dto.setPrice(new BigDecimal("99999.00")); // Fake price that must be ignored
        request.getItems().add(item2Dto);

        when(userRepository.findById(customerId)).thenReturn(Optional.of(customer));
        when(restaurantRepository.findById(restaurantId)).thenReturn(Optional.of(restaurant));
        when(menuItemRepository.findById(menuItemId1)).thenReturn(Optional.of(menuItem1));
        when(menuItemRepository.findById(menuItemId2)).thenReturn(Optional.of(menuItem2));
        when(orderRepository.save(any(Order.class))).thenAnswer(invocation -> invocation.getArgument(0));

        Order order = orderService.createOrder(request);

        assertNotNull(order);
        assertEquals(2, order.getItems().size());
        // 5600.00 + 2850.00 = 8450.00
        assertEquals(new BigDecimal("8450.00"), order.getTotalAmount());
        assertEquals(new BigDecimal("2800.00"), order.getItems().get(0).getPrice());
        assertEquals(new BigDecimal("950.00"), order.getItems().get(1).getPrice());
    }

    @Test
    @DisplayName("Should reject null order request")
    void shouldRejectNullOrderRequest() {
        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> {
            orderService.createOrder(null);
        });
        assertEquals("Order request cannot be null", ex.getMessage());
        verifyNoInteractions(orderRepository);
    }

    @Test
    @DisplayName("Should reject null or empty order item list")
    void shouldRejectNullOrEmptyItemList() {
        OrderRequestDTO nullItemsRequest = createBaseValidRequest();
        nullItemsRequest.setItems(null);

        IllegalArgumentException ex1 = assertThrows(IllegalArgumentException.class, () -> {
            orderService.createOrder(nullItemsRequest);
        });
        assertEquals("Order must contain at least one item", ex1.getMessage());

        OrderRequestDTO emptyItemsRequest = createBaseValidRequest();
        emptyItemsRequest.setItems(Collections.emptyList());

        IllegalArgumentException ex2 = assertThrows(IllegalArgumentException.class, () -> {
            orderService.createOrder(emptyItemsRequest);
        });
        assertEquals("Order must contain at least one item", ex2.getMessage());

        verifyNoInteractions(orderRepository);
    }

    @Test
    @DisplayName("Should reject missing or blank delivery address")
    void shouldRejectMissingOrBlankDeliveryAddress() {
        OrderRequestDTO nullAddressRequest = createBaseValidRequest();
        nullAddressRequest.setDeliveryAddress(null);

        IllegalArgumentException ex1 = assertThrows(IllegalArgumentException.class, () -> {
            orderService.createOrder(nullAddressRequest);
        });
        assertEquals("Delivery address is required", ex1.getMessage());

        OrderRequestDTO emptyAddressRequest = createBaseValidRequest();
        emptyAddressRequest.setDeliveryAddress("   ");

        IllegalArgumentException ex2 = assertThrows(IllegalArgumentException.class, () -> {
            orderService.createOrder(emptyAddressRequest);
        });
        assertEquals("Delivery address is required", ex2.getMessage());

        verifyNoInteractions(orderRepository);
    }

    @Test
    @DisplayName("Should reject missing restaurant ID")
    void shouldRejectMissingRestaurantId() {
        OrderRequestDTO request = createBaseValidRequest();
        request.setRestaurantId(null);

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> {
            orderService.createOrder(request);
        });
        assertEquals("Restaurant ID is required", ex.getMessage());
        verifyNoInteractions(orderRepository);
    }

    @Test
    @DisplayName("Should reject null order item element in items list")
    void shouldRejectNullOrderItemEntry() {
        OrderRequestDTO request = createBaseValidRequest();
        request.setItems(Collections.singletonList(null));

        when(userRepository.findById(customerId)).thenReturn(Optional.of(customer));
        when(restaurantRepository.findById(restaurantId)).thenReturn(Optional.of(restaurant));

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> {
            orderService.createOrder(request);
        });
        assertEquals("Order item cannot be null", ex.getMessage());
        verify(orderRepository, never()).save(any());
    }

    @Test
    @DisplayName("Should reject missing menu item ID in order item")
    void shouldRejectMissingMenuItemId() {
        OrderRequestDTO request = createBaseValidRequest();
        request.getItems().get(0).setMenuItemId(null);

        when(userRepository.findById(customerId)).thenReturn(Optional.of(customer));
        when(restaurantRepository.findById(restaurantId)).thenReturn(Optional.of(restaurant));

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> {
            orderService.createOrder(request);
        });
        assertEquals("Menu item ID is required", ex.getMessage());
        verify(orderRepository, never()).save(any());
    }

    @Test
    @DisplayName("Should reject null, zero, or negative quantities")
    void shouldRejectInvalidQuantities() {
        when(userRepository.findById(customerId)).thenReturn(Optional.of(customer));
        when(restaurantRepository.findById(restaurantId)).thenReturn(Optional.of(restaurant));

        // 1. Null quantity
        OrderRequestDTO nullQtyRequest = createBaseValidRequest();
        nullQtyRequest.getItems().get(0).setQuantity(null);
        IllegalArgumentException ex1 = assertThrows(IllegalArgumentException.class, () -> {
            orderService.createOrder(nullQtyRequest);
        });
        assertEquals("Item quantity must be greater than zero", ex1.getMessage());

        // 2. Zero quantity
        OrderRequestDTO zeroQtyRequest = createBaseValidRequest();
        zeroQtyRequest.getItems().get(0).setQuantity(0);
        IllegalArgumentException ex2 = assertThrows(IllegalArgumentException.class, () -> {
            orderService.createOrder(zeroQtyRequest);
        });
        assertEquals("Item quantity must be greater than zero", ex2.getMessage());

        // 3. Negative quantity
        OrderRequestDTO negQtyRequest = createBaseValidRequest();
        negQtyRequest.getItems().get(0).setQuantity(-5);
        IllegalArgumentException ex3 = assertThrows(IllegalArgumentException.class, () -> {
            orderService.createOrder(negQtyRequest);
        });
        assertEquals("Item quantity must be greater than zero", ex3.getMessage());

        verify(orderRepository, never()).save(any());
    }

    @Test
    @DisplayName("Should reject unavailable menu items")
    void shouldRejectUnavailableMenuItem() {
        menuItem1.setAvailable(false);

        OrderRequestDTO request = createBaseValidRequest();

        when(userRepository.findById(customerId)).thenReturn(Optional.of(customer));
        when(restaurantRepository.findById(restaurantId)).thenReturn(Optional.of(restaurant));
        when(menuItemRepository.findById(menuItemId1)).thenReturn(Optional.of(menuItem1));

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> {
            orderService.createOrder(request);
        });
        assertTrue(ex.getMessage().contains("Menu item is currently unavailable"));
        verify(orderRepository, never()).save(any());
    }

    @Test
    @DisplayName("Should reject menu items that belong to a different restaurant")
    void shouldRejectMenuItemFromDifferentRestaurant() {
        Restaurant otherRestaurant = new Restaurant();
        otherRestaurant.setId(UUID.randomUUID());
        otherRestaurant.setName("Different Cafe");

        menuItem1.setRestaurant(otherRestaurant);

        OrderRequestDTO request = createBaseValidRequest();

        when(userRepository.findById(customerId)).thenReturn(Optional.of(customer));
        when(restaurantRepository.findById(restaurantId)).thenReturn(Optional.of(restaurant));
        when(menuItemRepository.findById(menuItemId1)).thenReturn(Optional.of(menuItem1));

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> {
            orderService.createOrder(request);
        });
        assertTrue(ex.getMessage().contains("Menu item does not belong to the selected restaurant"));
        verify(orderRepository, never()).save(any());
    }

    @Test
    @DisplayName("Should reject menu items with null restaurant association")
    void shouldRejectMenuItemWithNullRestaurant() {
        menuItem1.setRestaurant(null);

        OrderRequestDTO request = createBaseValidRequest();

        when(userRepository.findById(customerId)).thenReturn(Optional.of(customer));
        when(restaurantRepository.findById(restaurantId)).thenReturn(Optional.of(restaurant));
        when(menuItemRepository.findById(menuItemId1)).thenReturn(Optional.of(menuItem1));

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> {
            orderService.createOrder(request);
        });
        assertTrue(ex.getMessage().contains("Menu item does not belong to the selected restaurant"));
        verify(orderRepository, never()).save(any());
    }

    @Test
    @DisplayName("Should reject null, zero, or negative database menu prices")
    void shouldRejectInvalidDatabasePrices() {
        when(userRepository.findById(customerId)).thenReturn(Optional.of(customer));
        when(restaurantRepository.findById(restaurantId)).thenReturn(Optional.of(restaurant));
        when(menuItemRepository.findById(menuItemId1)).thenReturn(Optional.of(menuItem1));

        // 1. Null price in DB
        menuItem1.setPrice(null);
        OrderRequestDTO req1 = createBaseValidRequest();
        IllegalArgumentException ex1 = assertThrows(IllegalArgumentException.class, () -> {
            orderService.createOrder(req1);
        });
        assertTrue(ex1.getMessage().contains("Invalid price for menu item"));

        // 2. Zero price in DB
        menuItem1.setPrice(BigDecimal.ZERO);
        OrderRequestDTO req2 = createBaseValidRequest();
        IllegalArgumentException ex2 = assertThrows(IllegalArgumentException.class, () -> {
            orderService.createOrder(req2);
        });
        assertTrue(ex2.getMessage().contains("Invalid price for menu item"));

        // 3. Negative price in DB
        menuItem1.setPrice(new BigDecimal("-100.00"));
        OrderRequestDTO req3 = createBaseValidRequest();
        IllegalArgumentException ex3 = assertThrows(IllegalArgumentException.class, () -> {
            orderService.createOrder(req3);
        });
        assertTrue(ex3.getMessage().contains("Invalid price for menu item"));

        verify(orderRepository, never()).save(any());
    }

    @Test
    @DisplayName("Should trim delivery address when persisting order")
    void shouldTrimDeliveryAddress() {
        OrderRequestDTO request = createBaseValidRequest();
        request.setDeliveryAddress("   Main Street, Tangalle   ");

        when(userRepository.findById(customerId)).thenReturn(Optional.of(customer));
        when(restaurantRepository.findById(restaurantId)).thenReturn(Optional.of(restaurant));
        when(menuItemRepository.findById(menuItemId1)).thenReturn(Optional.of(menuItem1));
        when(orderRepository.save(any(Order.class))).thenAnswer(invocation -> invocation.getArgument(0));

        Order order = orderService.createOrder(request);

        assertEquals("Main Street, Tangalle", order.getDeliveryAddress());
    }
}
