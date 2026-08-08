import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class AddressHeader extends StatelessWidget {
  const AddressHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20.r,
          backgroundColor: AppTheme.primary.withOpacity(0.1),
          child: Icon(
            Icons.location_on,
            color: AppTheme.primary,
            size: 20.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DELIVER TO',
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                  letterSpacing: 1.1,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Select Delivery Location',
                    style: GoogleFonts.outfit(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondary,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: AppTheme.primary,
                    size: 18.sp,
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: AppTheme.secondary.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.notifications_none_outlined,
            color: AppTheme.secondary,
            size: 24.sp,
          ),
        ),
      ],
    );
  }
}
