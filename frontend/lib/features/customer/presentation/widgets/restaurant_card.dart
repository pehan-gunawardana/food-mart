import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class RestaurantCard extends StatelessWidget {
  final String name;
  final String cuisine;
  final double rating;
  final int deliveryTimeMin;
  final int deliveryTimeMax;
  final double deliveryFee;
  final String imageUrl;

  const RestaurantCard({
    super.key,
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.deliveryTimeMin,
    required this.deliveryTimeMax,
    required this.deliveryFee,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isFreeDelivery = deliveryFee == 0.0;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/restaurant/detail',
          arguments: {
            'name': name,
            'cuisine': cuisine,
            'rating': rating,
            'deliveryTimeMin': deliveryTimeMin,
            'deliveryTimeMax': deliveryTimeMax,
            'deliveryFee': deliveryFee,
            'imageUrl': imageUrl,
          },
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 18.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 150.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                    color: AppTheme.secondary.withOpacity(0.05),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme.primary.withOpacity(0.05),
                          child: Center(
                            child: Icon(
                              Icons.restaurant_menu,
                              size: 48.sp,
                              color: AppTheme.primary.withOpacity(0.5),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 14.sp),
                        SizedBox(width: 4.w),
                        Text(
                          rating.toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isFreeDelivery)
                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'FREE DELIVERY',
                        style: GoogleFonts.poppins(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.outfit(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    cuisine,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                  SizedBox(height: 14.h),
                  const Divider(height: 1, color: Color(0xFFF1F2F6)),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: AppTheme.primary.withOpacity(0.8),
                            size: 16.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            '$deliveryTimeMin-$deliveryTimeMax mins',
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.delivery_dining_outlined,
                            color: AppTheme.primary.withOpacity(0.8),
                            size: 18.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            isFreeDelivery ? 'Free' : '\$${deliveryFee.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: isFreeDelivery ? Colors.green : AppTheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
