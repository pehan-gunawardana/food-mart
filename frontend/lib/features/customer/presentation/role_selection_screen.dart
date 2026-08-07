import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primary,
              AppTheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40.h),
                // App Logo Placeholder/Appetizing Title
                Icon(
                  Icons.fastfood,
                  size: 80.sp,
                  color: Colors.white,
                ),
                SizedBox(height: 16.h),
                Text(
                  'FoodMart',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 36.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Your Appetites, Delivered Fast',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(height: 48.h),
                Text(
                  'Select Your Portal',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 24.h),
                // Role Selection Cards
                _buildRoleCard(
                  context,
                  title: 'Order Food',
                  subtitle: 'Explore active local restaurants',
                  icon: Icons.restaurant,
                  routeName: '/customer/home',
                ),
                SizedBox(height: 16.h),
                _buildRoleCard(
                  context,
                  title: 'Restaurant Owner',
                  subtitle: 'Manage your menu and orders',
                  icon: Icons.storefront,
                  routeName: '/vendor/home',
                ),
                SizedBox(height: 16.h),
                _buildRoleCard(
                  context,
                  title: 'Delivery Rider',
                  subtitle: 'Deliver orders and earn revenue',
                  icon: Icons.delivery_dining,
                  routeName: '/rider/home',
                ),
                const Spacer(),
                Text(
                  'v1.0.0',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String routeName,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, routeName),
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28.r,
                backgroundColor: AppTheme.primary.withOpacity(0.1),
                child: Icon(
                  icon,
                  color: AppTheme.primary,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        color: AppTheme.secondary,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.secondary.withOpacity(0.4),
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
