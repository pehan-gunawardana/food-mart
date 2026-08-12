package com.foodmart.backend.models;

public enum OrderStatus {
    PENDING,
    ACCEPTED,
    PREPARING,
    RIDER_ASSIGNED,
    PICKED_UP,
    OUT_FOR_DELIVERY,
    DELIVERED,
    CANCELLED
}
