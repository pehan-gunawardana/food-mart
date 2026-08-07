import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search for restaurants, kottu, rice...',
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey[400],
            fontSize: 14.sp,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppTheme.secondary.withOpacity(0.6),
            size: 22.sp,
          ),
          suffixIcon: Container(
            margin: EdgeInsets.all(6.r),
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.tune,
              color: Colors.white,
              size: 16.sp,
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        ),
      ),
    );
  }
}
