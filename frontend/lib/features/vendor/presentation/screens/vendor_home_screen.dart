import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../customer/presentation/bloc/restaurant_cubit.dart';
import '../../../customer/presentation/bloc/restaurant_state.dart';
import '../../../customer/data/models/order_model.dart';
import '../bloc/vendor_orders_cubit.dart';
import '../bloc/vendor_orders_state.dart';

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({super.key});

  @override
  State<VendorHomeScreen> createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isOnline = true;
  String _restaurantId = '';
  String _restaurantName = 'Rasa Kottu Hut';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    // Dynamically retrieve seeded restaurant ID from RestaurantCubit
    final restaurantState = context.read<RestaurantCubit>().state;
    if (restaurantState is RestaurantLoaded && restaurantState.restaurants.isNotEmpty) {
      final rasaKottu = restaurantState.restaurants.firstWhere(
        (r) =>
            r.name.toLowerCase().contains('kottu') ||
            r.name.toLowerCase().contains('rasa'),
        orElse: () => restaurantState.restaurants.first,
      );
      _restaurantId = rasaKottu.id;
      _restaurantName = rasaKottu.name;
    }

    _refreshOrders();
  }

  void _refreshOrders() {
    if (_restaurantId.isNotEmpty) {
      context.read<VendorOrdersCubit>().fetchOrders(_restaurantId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    final String hour = date.hour.toString().padLeft(2, '0');
    final String minute = date.minute.toString().padLeft(2, '0');
    return '${date.year}-$month-$day $hour:$minute';
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders, int tabIndex) {
    return orders.where((order) {
      final status = order.status.toUpperCase();
      if (tabIndex == 0) {
        // New Orders
        return status == 'PENDING';
      } else if (tabIndex == 1) {
        // Preparing
        return status == 'ACCEPTED' || status == 'PREPARING';
      } else {
        // Ready / Dispatched
        return status == 'OUT_FOR_DELIVERY' ||
            status == 'DELIVERED' ||
            status == 'CANCELLED';
      }
    }).toList();
  }

  Widget _buildOrderAction(OrderModel order) {
    final status = order.status.toUpperCase();
    String buttonText = '';
    String nextStatus = '';

    if (status == 'PENDING') {
      buttonText = 'Accept Order';
      nextStatus = 'PREPARING';
    } else if (status == 'ACCEPTED' || status == 'PREPARING') {
      buttonText = 'Mark Ready / Dispatch';
      nextStatus = 'OUT_FOR_DELIVERY';
    } else if (status == 'OUT_FOR_DELIVERY') {
      buttonText = 'Mark Delivered';
      nextStatus = 'DELIVERED';
    }

    if (buttonText.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      height: 44.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        onPressed: () {
          context.read<VendorOrdersCubit>().updateStatus(
                order.id,
                nextStatus,
                _restaurantId,
              );
        },
        child: Text(
          buttonText,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
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
        backgroundColor: AppTheme.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _restaurantName,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: Colors.white,
              ),
            ),
            Text(
              'Vendor Dashboard',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Text(
                _isOnline ? 'ONLINE' : 'OFFLINE',
                style: GoogleFonts.outfit(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: _isOnline ? Colors.green : Colors.grey[400],
                ),
              ),
              Switch(
                value: _isOnline,
                activeColor: Colors.green,
                inactiveThumbColor: Colors.grey[600],
                inactiveTrackColor: Colors.grey[800],
                onChanged: (val) {
                  setState(() {
                    _isOnline = val;
                  });
                },
              ),
            ],
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          // Tab bar selection
          Container(
            color: AppTheme.secondary,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primary,
              indicatorWeight: 3.h,
              labelColor: AppTheme.primary,
              unselectedLabelColor: Colors.grey[400],
              labelStyle: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
              unselectedLabelStyle: GoogleFonts.outfit(
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
              ),
              tabs: const [
                Tab(text: 'New Orders'),
                Tab(text: 'Preparing'),
                Tab(text: 'Ready/Dispatched'),
              ],
            ),
          ),

          // Orders content
          Expanded(
            child: BlocBuilder<VendorOrdersCubit, VendorOrdersState>(
              builder: (context, state) {
                if (state is VendorOrdersLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  );
                } else if (state is VendorOrdersLoaded) {
                  final filtered = _filterOrders(state.orders, _tabController.index);

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64.sp,
                            color: Colors.grey[300],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No orders in this tab',
                            style: GoogleFonts.outfit(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.secondary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'New customer requests will show up here.',
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppTheme.primary,
                    onRefresh: () async => _refreshOrders(),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: EdgeInsets.all(20.r),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final order = filtered[index];

                        return Container(
                          margin: EdgeInsets.only(bottom: 16.h),
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: const Color(0xFFF1F2F6)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.01),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Card Header: Order number and date
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Order #${order.id.substring(0, 8).toUpperCase()}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.secondary,
                                    ),
                                  ),
                                  Text(
                                    _formatDate(order.createdAt),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.sp,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              
                              // Delivery address
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined,
                                      color: Colors.grey[500], size: 14.sp),
                                  SizedBox(width: 4.w),
                                  Expanded(
                                    child: Text(
                                      order.deliveryAddress,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 12.h),
                              const Divider(height: 1, color: Color(0xFFF1F2F6)),
                              SizedBox(height: 12.h),

                              // Items sublist
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: order.items.length,
                                itemBuilder: (context, itemIdx) {
                                  final item = order.items[itemIdx];
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 6.h),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${item.quantity}x  ${item.menuItem.name}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13.sp,
                                            color: AppTheme.secondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          'LKR ${(item.price * item.quantity).toInt()}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13.sp,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                              SizedBox(height: 12.h),
                              const Divider(height: 1, color: Color(0xFFF1F2F6)),
                              SizedBox(height: 12.h),

                              // Total Sum
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Revenue',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  Text(
                                    'LKR ${order.totalAmount.toInt()}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 16.h),

                              // Dynamic Action Button
                              _buildOrderAction(order),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                } else if (state is VendorOrdersError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.r),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              color: AppTheme.primary, size: 48.sp),
                          SizedBox(height: 16.h),
                          Text(
                            'Failed to load orders',
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
                            onPressed: () => _refreshOrders(),
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
          ),
        ],
      ),
    );
  }
}
