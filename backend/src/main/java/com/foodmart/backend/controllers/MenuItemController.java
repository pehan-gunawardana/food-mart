package com.foodmart.backend.controllers;

import com.foodmart.backend.models.MenuItem;
import com.foodmart.backend.services.MenuItemService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/restaurants/{restaurantId}/menu")
@CrossOrigin(origins = "*")
public class MenuItemController {

    private final MenuItemService menuItemService;

    @Autowired
    public MenuItemController(MenuItemService menuItemService) {
        this.menuItemService = menuItemService;
    }

    @PostMapping
    public ResponseEntity<?> addMenuItem(
            @PathVariable UUID restaurantId,
            @RequestBody MenuItem menuItem) {
        try {
            MenuItem created = menuItemService.addMenuItem(restaurantId, menuItem);
            return new ResponseEntity<>(created, HttpStatus.CREATED);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping
    public ResponseEntity<List<MenuItem>> listMenuItems(@PathVariable UUID restaurantId) {
        List<MenuItem> items = menuItemService.listMenuItemsByRestaurant(restaurantId);
        return new ResponseEntity<>(items, HttpStatus.OK);
    }
}
