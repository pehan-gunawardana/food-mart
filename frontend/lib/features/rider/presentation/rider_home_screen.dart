import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/bloc/auth_cubit.dart';
import '../../auth/presentation/bloc/auth_state.dart';
import 'bloc/rider_orders_cubit.dart';
import 'bloc/rider_orders_state.dart';
import '../../customer/data/models/order_model.dart';

class RiderHomeScreen extends StatefulWidget {
  const RiderHomeScreen({super.key});

  @override
  State<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends State<RiderHomeScreen> {
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      context.read<RiderOrdersCubit>().fetchOrders(authState.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final riderId = authState is Authenticated ? authState.user.id : '';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Rider Dashboard',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthCubit>().logout();
              },
            ),
          ],
          bottom: TabBar(
            indicatorColor: AppTheme.primary,
            labelColor: AppTheme.primary,
            unselectedLabelColor: Colors.grey,
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14.sp),
            tabs: const [
              Tab(text: 'Active Deliveries'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: BlocBuilder<RiderOrdersCubit, RiderOrdersState>(
          builder: (context, state) {
            if (state is RiderOrdersLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              );
            } else if (state is RiderOrdersError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.message}'),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        if (riderId.isNotEmpty) {
                          context.read<RiderOrdersCubit>().fetchOrders(riderId);
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (state is RiderOrdersLoaded) {
              final orders = state.orders;
              final activeOrders = orders.where((o) => o.status.toUpperCase() == 'OUT_FOR_DELIVERY').toList();
              final completedOrders = orders.where((o) => o.status.toUpperCase() == 'DELIVERED').toList();

              return TabBarView(
                children: [
                  _buildOrderList(activeOrders, state.updatingOrderId, riderId, isActive: true),
                  _buildOrderList(completedOrders, state.updatingOrderId, riderId, isActive: false),
                ],
              );
            }
            return const Center(child: Text('No orders found.'));
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, String? updatingOrderId, String riderId, {required bool isActive}) {
    return RefreshIndicator(
      onRefresh: () async {
        if (riderId.isNotEmpty) {
          await context.read<RiderOrdersCubit>().fetchOrders(riderId);
        }
      },
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          if (isActive) ...[
            _buildDutyCard(),
            SizedBox(height: 16.h),
            _buildStatsRow(orders.length),
            SizedBox(height: 24.h),
          ] else ...[
            _buildStatsRow(orders.length),
            SizedBox(height: 24.h),
          ],
          Text(
            isActive ? 'Active Assignments (${orders.length})' : 'Delivery History (${orders.length})',
            style: GoogleFonts.outfit(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondary,
            ),
          ),
          SizedBox(height: 12.h),
          if (orders.isEmpty)
            _buildEmptyPlaceholder(isActive)
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildOrderCard(order, updatingOrderId, isActive);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDutyCard() {
    return Card(
      color: AppTheme.secondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Delivery Duty',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _isOnline ? 'You are currently: ONLINE' : 'You are currently: OFFLINE',
                  style: GoogleFonts.poppins(
                    color: _isOnline ? Colors.greenAccent : Colors.grey,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Switch(
              value: _isOnline,
              onChanged: (val) {
                setState(() {
                  _isOnline = val;
                });
              },
              activeThumbColor: Colors.greenAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(int count) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Deliveries', '$count', Icons.check_circle_outline),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard('Earnings', '\$${(count * 5.0).toStringAsFixed(2)}', Icons.sports_motorsports),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.primary, size: 24.sp),
            SizedBox(height: 12.h),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPlaceholder(bool isActive) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.motorcycle_outlined : Icons.history,
              size: 64.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              isActive ? 'No active delivery assignments' : 'No completed deliveries yet',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, String? updatingOrderId, bool isActive) {
    final isUpdating = updatingOrderId == order.id;

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order ID: #${order.id.substring(0, 8).toUpperCase()}',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                    color: AppTheme.secondary,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    order.status.replaceAll('_', ' '),
                    style: GoogleFonts.poppins(
                      color: isActive ? Colors.orange : Colors.green,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, color: AppTheme.primary, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery Address',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[500],
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        order.deliveryAddress,
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: AppTheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[500],
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '\$${order.totalAmount.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  _formatDate(order.createdAt),
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            if (isActive) ...[
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: isUpdating
                      ? null
                      : () => context.read<RiderOrdersCubit>().markAsDelivered(order.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: isUpdating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Mark as Delivered',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} - ${date.day}/${date.month}/${date.year}';
  }
}
