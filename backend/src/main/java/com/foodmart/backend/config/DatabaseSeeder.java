package com.foodmart.backend.config;

import com.foodmart.backend.models.MenuItem;
import com.foodmart.backend.models.Restaurant;
import com.foodmart.backend.models.Role;
import com.foodmart.backend.models.User;
import com.foodmart.backend.repositories.MenuItemRepository;
import com.foodmart.backend.repositories.RestaurantRepository;
import com.foodmart.backend.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;

@Component
public class DatabaseSeeder implements CommandLineRunner {

    private final UserRepository userRepository;
    private final RestaurantRepository restaurantRepository;
    private final MenuItemRepository menuItemRepository;

    @Autowired
    public DatabaseSeeder(UserRepository userRepository,
                          RestaurantRepository restaurantRepository,
                          MenuItemRepository menuItemRepository) {
        this.userRepository = userRepository;
        this.restaurantRepository = restaurantRepository;
        this.menuItemRepository = menuItemRepository;
    }

    @Override
    public void run(String... args) throws Exception {
        if (restaurantRepository.count() == 0) {
            System.out.println("Database is empty. Seeding initial food mart mock data for Tangalle region...");

            // 1. Create and save Users
            User admin = new User();
            admin.setName("Admin User");
            admin.setEmail("admin@foodmart.com");
            admin.setPhone("0711234567");
            admin.setPasswordHash("admin123");
            admin.setRole(Role.ADMIN);
            userRepository.save(admin);

            User vendor1 = new User();
            vendor1.setName("Vendor One");
            vendor1.setEmail("vendor1@foodmart.com");
            vendor1.setPhone("0711234568");
            vendor1.setPasswordHash("vendor123");
            vendor1.setRole(Role.VENDOR);
            userRepository.save(vendor1);

            User vendor2 = new User();
            vendor2.setName("Vendor Two");
            vendor2.setEmail("vendor2@foodmart.com");
            vendor2.setPhone("0711234569");
            vendor2.setPasswordHash("vendor123");
            vendor2.setRole(Role.VENDOR);
            userRepository.save(vendor2);

            // 2. Create and save Restaurant 1
            Restaurant r1 = new Restaurant();
            r1.setName("Tangalle Seafoods");
            r1.setDescription("Premium local fresh seafood from Tangalle Bay.");
            r1.setAddress("Beach Road, Tangalle");
            r1.setContactNumber("0471234567");
            r1.setActive(true);
            r1.setCoverImageUrl("https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&q=80&w=600");
            r1.setOwner(vendor1);
            restaurantRepository.save(r1);

            // Menu Items for Restaurant 1
            MenuItem item1 = new MenuItem();
            item1.setName("Jumbo Prawns");
            item1.setDescription("Freshly caught giant lagoon prawns grilled with butter and garlic sauce.");
            item1.setPrice(new BigDecimal("2800"));
            item1.setAvailable(true);
            item1.setImageUrl("https://images.unsplash.com/photo-1559742811-824289528580?auto=format&fit=crop&q=80&w=600");
            item1.setRestaurant(r1);
            menuItemRepository.save(item1);

            MenuItem item2 = new MenuItem();
            item2.setName("Cuttlefish Curry");
            item2.setDescription("Spicy Sri Lankan cuttlefish curry made with native black spices and coconut milk.");
            item2.setPrice(new BigDecimal("1450"));
            item2.setAvailable(true);
            item2.setImageUrl("https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&q=80&w=600");
            item2.setRestaurant(r1);
            menuItemRepository.save(item2);

            MenuItem item3 = new MenuItem();
            item3.setName("Fried Rice");
            item3.setDescription("Wok-fried premium basmati rice with mixed vegetables and fresh seafood seasonings.");
            item3.setPrice(new BigDecimal("950"));
            item3.setAvailable(true);
            item3.setImageUrl("https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&q=80&w=600");
            item3.setRestaurant(r1);
            menuItemRepository.save(item3);

            // 3. Create and save Restaurant 2
            Restaurant r2 = new Restaurant();
            r2.setName("Rasa Kottu Hut");
            r2.setDescription("The ultimate local kottu corner. Spiced to perfection.");
            r2.setAddress("Main Street, Tangalle");
            r2.setContactNumber("0471234568");
            r2.setActive(true);
            r2.setCoverImageUrl("https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&q=80&w=600");
            r2.setOwner(vendor2);
            restaurantRepository.save(r2);

            // Menu Items for Restaurant 2
            MenuItem item4 = new MenuItem();
            item4.setName("Chicken Cheese Kottu");
            item4.setDescription("Stir-fried shredded roti scrambled with chicken, fresh eggs, veggies, and creamy melted cheese.");
            item4.setPrice(new BigDecimal("1150"));
            item4.setAvailable(true);
            item4.setImageUrl("https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&q=80&w=600");
            item4.setRestaurant(r2);
            menuItemRepository.save(item4);

            MenuItem item5 = new MenuItem();
            item5.setName("Dolphin Kottu");
            item5.setDescription("Classic Sri Lankan Dolphin Kottu featuring large cube roti, chopped capsicum, and thick curry gravy.");
            item5.setPrice(new BigDecimal("950"));
            item5.setAvailable(true);
            item5.setImageUrl("https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&q=80&w=600");
            item5.setRestaurant(r2);
            menuItemRepository.save(item5);

            MenuItem item6 = new MenuItem();
            item6.setName("Iced Milo");
            item6.setDescription("Creamy malt chocolate beverage served ice cold with extra Milo powder scoop on top.");
            item6.setPrice(new BigDecimal("380"));
            item6.setAvailable(true);
            item6.setImageUrl("https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&q=80&w=600");
            item6.setRestaurant(r2);
            menuItemRepository.save(item6);

            System.out.println("Food mart mock data successfully seeded!");
        } else {
            System.out.println("Database contains existing records. Skipping data seeding.");
        }
    }
}
