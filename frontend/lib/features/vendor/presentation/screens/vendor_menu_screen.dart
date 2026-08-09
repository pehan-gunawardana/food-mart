import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../customer/data/models/menu_item_model.dart';
import '../bloc/vendor_menu_cubit.dart';
import '../bloc/vendor_menu_state.dart';

class VendorMenuScreen extends StatefulWidget {
  final String restaurantId;

  const VendorMenuScreen({super.key, required this.restaurantId});

  @override
  State<VendorMenuScreen> createState() => _VendorMenuScreenState();
}

class _VendorMenuScreenState extends State<VendorMenuScreen> {
  @override
  void initState() {
    super.initState();
    _fetchMenu();
  }

  @override
  void didUpdateWidget(covariant VendorMenuScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.restaurantId != widget.restaurantId) {
      _fetchMenu();
    }
  }

  void _fetchMenu() {
    if (widget.restaurantId.isNotEmpty) {
      context.read<VendorMenuCubit>().fetchMenuItems(widget.restaurantId);
    }
  }

  void _showAddMenuItemBottomSheet() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final imageUrlController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            padding: EdgeInsets.all(24.r),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Modal Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Add New Menu Item',
                          style: GoogleFonts.outfit(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondary,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(bottomSheetContext),
                          icon: Icon(Icons.close, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Name Field
                    Text(
                      'Item Name',
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    TextFormField(
                      controller: nameController,
                      style: GoogleFonts.poppins(fontSize: 14.sp),
                      decoration: InputDecoration(
                        hintText: 'e.g., Chicken Kottu Special',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter item name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 14.h),

                    // Description Field
                    Text(
                      'Description',
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 2,
                      style: GoogleFonts.poppins(fontSize: 14.sp),
                      decoration: InputDecoration(
                        hintText: 'Short appetizing description of ingredients...',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter item description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 14.h),

                    // Price Field
                    Text(
                      'Price (LKR)',
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    TextFormField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: GoogleFonts.poppins(fontSize: 14.sp),
                      decoration: InputDecoration(
                        hintText: 'e.g., 1250',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter price';
                        }
                        final parsed = double.tryParse(val.trim());
                        if (parsed == null || parsed <= 0) {
                          return 'Enter a valid positive price number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 14.h),

                    // Image URL Field
                    Text(
                      'Image URL',
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    TextFormField(
                      controller: imageUrlController,
                      style: GoogleFonts.poppins(fontSize: 14.sp),
                      decoration: InputDecoration(
                        hintText: 'https://images.unsplash.com/...',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final newItem = MenuItemModel(
                              id: '',
                              name: nameController.text.trim(),
                              description: descriptionController.text.trim(),
                              price: double.parse(priceController.text.trim()),
                              imageUrl: imageUrlController.text.trim().isNotEmpty
                                  ? imageUrlController.text.trim()
                                  : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500',
                              isAvailable: true,
                            );

                            Navigator.pop(bottomSheetContext);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Adding new menu item...'),
                                duration: Duration(seconds: 1),
                              ),
                            );

                            final success = await context.read<VendorMenuCubit>().addMenuItem(
                                  widget.restaurantId,
                                  newItem,
                                );

                            if (mounted && success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Menu item added successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          }
                        },
                        child: Text(
                          'Save Menu Item',
                          style: GoogleFonts.outfit(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: BlocBuilder<VendorMenuCubit, VendorMenuState>(
        builder: (context, state) {
          if (state is VendorMenuLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          } else if (state is VendorMenuLoaded) {
            final items = state.items;

            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.restaurant_menu_outlined,
                      size: 64.sp,
                      color: Colors.grey[300],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No Menu Items Found',
                      style: GoogleFonts.outfit(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Tap the + button below to add your first dish.',
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: () async => _fetchMenu(),
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(20.r, 20.r, 20.r, 80.r),
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isToggling = state.togglingItemId == item.id;

                  return Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFF1F2F6)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(8),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Image Preview
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.network(
                            item.imageUrl,
                            width: 76.r,
                            height: 76.r,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 76.r,
                                height: 76.r,
                                color: const Color(0xFFF1F2F6),
                                child: Icon(
                                  Icons.fastfood,
                                  color: Colors.grey[400],
                                  size: 32.sp,
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 14.w),

                        // Info Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: GoogleFonts.outfit(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.secondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                item.description,
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  color: Colors.grey[500],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                'LKR ${item.price.toInt()}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),

                        // Availability Toggle Switch
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.isAvailable ? 'In Stock' : 'Unavailable',
                              style: GoogleFonts.outfit(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: item.isAvailable
                                    ? const Color(0xFF2ECC71)
                                    : Colors.grey[400],
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Switch(
                              value: item.isAvailable,
                              activeThumbColor: AppTheme.primary,
                              activeTrackColor: AppTheme.primary.withAlpha(80),
                              inactiveThumbColor: Colors.grey[400],
                              inactiveTrackColor: Colors.grey[200],
                              onChanged: isToggling
                                  ? null
                                  : (val) {
                                      context
                                          .read<VendorMenuCubit>()
                                          .toggleItemAvailability(
                                            widget.restaurantId,
                                            item.id,
                                            val,
                                          );
                                    },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          } else if (state is VendorMenuError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppTheme.primary,
                      size: 48.sp,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Failed to load menu items',
                      style: GoogleFonts.outfit(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () => _fetchMenu(),
                      child: Text(
                        'Retry',
                        style: GoogleFonts.outfit(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.secondary,
        elevation: 4,
        onPressed: _showAddMenuItemBottomSheet,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Item',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }
}
