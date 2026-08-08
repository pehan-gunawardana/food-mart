import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/cart_cubit.dart';
import '../bloc/cart_state.dart';
import '../bloc/order_cubit.dart';
import '../bloc/order_state.dart';

class CheckoutScreen extends StatefulWidget {
  final String restaurantId;

  const CheckoutScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _addressController =
      TextEditingController(text: "No 15, Beach Road, Tangalle");
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 64.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Order Placed Successfully!',
                style: GoogleFonts.outfit(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondary,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Your delicious meal is being prepared and will be delivered shortly.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(dialogCtx).pop(); // Close dialog
                    context.read<CartCubit>().clearCart(); // Clear cart state
                    Navigator.of(context).popUntil((route) => route.isFirst); // Back to HomeScreen
                  },
                  child: Text(
                    'Back to Home',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppTheme.secondary,
            fontSize: 20.sp,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.secondary,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<OrderCubit, OrderState>(
        listener: (context, state) {
          if (state is OrderSuccess) {
            _showSuccessDialog(context);
          } else if (state is OrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error placing order: ${state.message}',
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: AppTheme.primary,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Items Summary',
                        style: GoogleFonts.outfit(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondary,
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Cart items builder list
                      BlocBuilder<CartCubit, CartState>(
                        builder: (context, cartState) {
                          if (cartState.items.isEmpty) {
                            return Center(
                              child: Text(
                                'No items in cart.',
                                style: GoogleFonts.poppins(color: Colors.grey[500]),
                              ),
                            );
                          }
                          return Container(
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: const Color(0xFFF1F2F6)),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: cartState.items.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(color: Color(0xFFF1F2F6), height: 24),
                              itemBuilder: (context, index) {
                                final cartItem = cartState.items[index];
                                return Row(
                                  children: [
                                    Container(
                                      width: 48.w,
                                      height: 48.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8.r),
                                        color: AppTheme.secondary.withOpacity(0.05),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8.r),
                                        child: Image.network(
                                          cartItem.item.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              Icon(Icons.fastfood, size: 24.sp, color: AppTheme.primary),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cartItem.item.name,
                                            style: GoogleFonts.outfit(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.secondary,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            'Qty: ${cartItem.quantity}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12.sp,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'LKR ${cartItem.totalPrice.toInt()}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.secondary,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 24.h),

                      // Delivery Address Section
                      Text(
                        'Delivery Address',
                        style: GoogleFonts.outfit(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      TextFormField(
                        controller: _addressController,
                        style: GoogleFonts.poppins(fontSize: 14.sp, color: AppTheme.secondary),
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Enter your delivery address...',
                          hintStyle: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.all(16.r),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: const BorderSide(color: Color(0xFFF1F2F6)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: const BorderSide(color: AppTheme.primary),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Address is required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Section: Summary & Checkout Button
              Container(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: BlocBuilder<CartCubit, CartState>(
                  builder: (context, cartState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Amount',
                              style: GoogleFonts.outfit(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[500],
                              ),
                            ),
                            Text(
                              'LKR ${cartState.totalPrice.toInt()}',
                              style: GoogleFonts.poppins(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        BlocBuilder<OrderCubit, OrderState>(
                          builder: (context, orderState) {
                            final isLoading = orderState is OrderLoading;

                            return SizedBox(
                              width: double.infinity,
                              height: 54.h,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate() &&
                                            cartState.items.isNotEmpty) {
                                          context.read<OrderCubit>().placeOrder(
                                                restaurantId: widget.restaurantId,
                                                deliveryAddress: _addressController.text.trim(),
                                                items: cartState.items,
                                              );
                                        }
                                      },
                                child: isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : Text(
                                        'Place Order',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
