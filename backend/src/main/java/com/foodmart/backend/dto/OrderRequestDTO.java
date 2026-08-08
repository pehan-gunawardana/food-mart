package com.foodmart.backend.dto;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Getter
@Setter
public class OrderRequestDTO {
    private UUID customerId;
    private UUID restaurantId;
    private String deliveryAddress;
    private List<OrderItemDTO> items;

    @Getter
    @Setter
    public static class OrderItemDTO {
        private UUID menuItemId;
        private Integer quantity;
        private BigDecimal price;
    }
}
