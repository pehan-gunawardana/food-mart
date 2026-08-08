import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/menu_item_model.dart';
import '../../data/models/cart_item_model.dart';
import '../bloc/cart_cubit.dart';
import '../bloc/cart_state.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItemModel item;

  const MenuItemCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final cartItem = state.items.firstWhere(
          (element) => element.item.id == item.id,
          orElse: () => CartItemModel(item: item, quantity: 0),
        );
        final quantity = cartItem.quantity;
        final showCounter = quantity > 0;

        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFF1F2F6), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.01),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.outfit(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.grey[500],
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'LKR ${item.price.toInt()}',
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 90.w,
                    height: 90.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: AppTheme.secondary.withOpacity(0.05),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.fastfood,
                              size: 32.sp,
                              color: AppTheme.primary.withOpacity(0.4),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -10.h,
                    left: 10.w,
                    right: 10.w,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: 32.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: AppTheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: !showCounter
                      ? Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => context.read<CartCubit>().addItem(item),
                            borderRadius: BorderRadius.circular(20.r),
                            child: Center(
                              child: Text(
                                'ADD',
                                style: GoogleFonts.poppins(
                                  color: AppTheme.primary,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => context.read<CartCubit>().removeItem(item),
                              child: Container(
                                padding: EdgeInsets.all(6.r),
                                child: Icon(
                                  Icons.remove,
                                  color: AppTheme.primary,
                                  size: 16.sp,
                                ),
                              ),
                            ),
                            Text(
                              quantity.toString(),
                              style: GoogleFonts.poppins(
                                color: AppTheme.secondary,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.read<CartCubit>().addItem(item),
                              child: Container(
                                padding: EdgeInsets.all(6.r),
                                child: Icon(
                                  Icons.add,
                                  color: AppTheme.primary,
                                  size: 16.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
      },
    );
  }
}
