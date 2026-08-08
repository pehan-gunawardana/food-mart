import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/address_header.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/category_list.dart';
import '../widgets/promo_banner.dart';
import '../widgets/restaurant_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                
                // Address Header
                const AddressHeader(),
                SizedBox(height: 20.h),
                
                // Welcome text
                Text(
                  'Hello, Foodie! 👋',
                  style: GoogleFonts.outfit(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondary,
                  ),
                ),
                Text(
                  'What are you craving today?',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey[500],
                  ),
                ),
                SizedBox(height: 20.h),

                // Search Bar
                const CustomSearchBar(),
                SizedBox(height: 24.h),

                // Promo Banner Carousel
                const PromoBanner(),
                SizedBox(height: 24.h),

                // Categories Scroll List
                Text(
                  'Categories',
                  style: GoogleFonts.outfit(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondary,
                  ),
                ),
                SizedBox(height: 12.h),
                const CategoryScrollList(),
                SizedBox(height: 24.h),

                // Restaurant Listings Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Popular Near You',
                      style: GoogleFonts.outfit(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'See All',
                        style: GoogleFonts.poppins(
                          color: AppTheme.primary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                // Restaurant List
                const RestaurantCard(
                  name: 'Pizza Palace',
                  cuisine: 'Italian • Pizza • Pasta • Burgers',
                  rating: 4.8,
                  deliveryTimeMin: 15,
                  deliveryTimeMax: 25,
                  deliveryFee: 0.0,
                  imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&q=80&w=600',
                ),
                const RestaurantCard(
                  name: 'Rice & Curry Hot Spot',
                  cuisine: 'Sri Lankan • Traditional Rice & Curry',
                  rating: 4.6,
                  deliveryTimeMin: 20,
                  deliveryTimeMax: 30,
                  deliveryFee: 1.50,
                  imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&q=80&w=600',
                ),
                const RestaurantCard(
                  name: 'Kottu Hub',
                  cuisine: 'Street Food • Cheese Kottu • Short Eats',
                  rating: 4.7,
                  deliveryTimeMin: 10,
                  deliveryTimeMax: 20,
                  deliveryFee: 0.0,
                  imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&q=80&w=600',
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
