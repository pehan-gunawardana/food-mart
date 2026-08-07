import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/menu_item_card.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Map<String, dynamic> restaurantArgs;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurantArgs,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, int> _cartItems = {}; // Map of item name to quantity

  final List<String> _categories = ["Popular", "Kottu", "Rice & Curry", "Beverages"];

  // Mock Menu Items
  final List<Map<String, dynamic>> _menuItems = [
    {
      'name': 'Double Cheese Margherita',
      'description': 'Classic pizza loaded with extra mozzarella cheese and organic tomato sauce.',
      'price': 1250,
      'category': 'Popular',
      'imageUrl': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&q=80&w=600',
    },
    {
      'name': 'Cheese Kottu Chicken',
      'description': 'Traditional chopped flatbread stir-fried with chicken, veggies, eggs, and rich cheese sauce.',
      'price': 950,
      'category': 'Popular',
      'imageUrl': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&q=80&w=600',
    },
    {
      'name': 'Chicken Kottu',
      'description': 'Spicy chopped flatbread scrambled with tender chicken cubes and savory Sri Lankan gravy.',
      'price': 800,
      'category': 'Kottu',
      'imageUrl': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&q=80&w=600',
    },
    {
      'name': 'Dolphin Kottu Cheese',
      'description': 'Large chunk chopped flatbread tossed with capsicum, onions, eggs, and dynamic seasonings.',
      'price': 900,
      'category': 'Kottu',
      'imageUrl': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&q=80&w=600',
    },
    {
      'name': 'Chicken Rice & Curry',
      'description': 'Steaming white basmati rice served with classic chicken curry, dhal, and fresh sambol.',
      'price': 650,
      'category': 'Rice & Curry',
      'imageUrl': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&q=80&w=600',
    },
    {
      'name': 'Egg Fried Rice',
      'description': 'Fragrant wok-tossed jasmine rice scrambled with eggs, spring onions, and premium soy sauce.',
      'price': 550,
      'category': 'Rice & Curry',
      'imageUrl': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&q=80&w=600',
    },
    {
      'name': 'Fresh Lime Juice',
      'description': 'Chilled freshly squeezed lime juice with a dash of sea salt and organic simple syrup.',
      'price': 300,
      'category': 'Beverages',
      'imageUrl': 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&q=80&w=600',
    },
    {
      'name': 'Iced Coffee Latte',
      'description': 'Smooth local coffee blend brewed fresh and served ice cold with sweetened condensed milk.',
      'price': 350,
      'category': 'Beverages',
      'imageUrl': 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&q=80&w=600',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int get totalItems => _cartItems.values.fold(0, (sum, qty) => sum + qty);

  int get totalPrice => _cartItems.entries.fold(0, (sum, entry) {
        final item = _menuItems.firstWhere((x) => x['name'] == entry.key);
        return sum + (item['price'] as int) * entry.value;
      });

  void _addToCart(String itemName) {
    setState(() {
      _cartItems[itemName] = (_cartItems[itemName] ?? 0) + 1;
    });
  }

  void _removeFromCart(String itemName) {
    setState(() {
      if (_cartItems.containsKey(itemName)) {
        if (_cartItems[itemName] == 1) {
          _cartItems.remove(itemName);
        } else {
          _cartItems[itemName] = _cartItems[itemName]! - 1;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.restaurantArgs['name'] as String? ?? 'Restaurant';
    final cuisine = widget.restaurantArgs['cuisine'] as String? ?? 'Cuisine';
    final rating = widget.restaurantArgs['rating'] as double? ?? 4.5;
    final deliveryTimeMin = widget.restaurantArgs['deliveryTimeMin'] as int? ?? 20;
    final deliveryTimeMax = widget.restaurantArgs['deliveryTimeMax'] as int? ?? 30;
    final imageUrl = widget.restaurantArgs['imageUrl'] as String? ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Collapsible Pinned Header
              SliverAppBar(
                expandedHeight: 220.h,
                pinned: true,
                elevation: 0,
                backgroundColor: AppTheme.secondary,
                foregroundColor: Colors.white,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppTheme.primary.withOpacity(0.1),
                          child: Icon(Icons.restaurant, size: 64.sp, color: AppTheme.primary),
                        ),
                      ),
                      // Gradient overlay to make back button and details readable
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Restaurant details
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: GoogleFonts.outfit(
                                fontSize: 26.sp,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondary,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.star, color: AppTheme.primary, size: 16.sp),
                                SizedBox(width: 4.w),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.primary,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        cuisine,
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      // Meta stats (delivery time, address)
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, color: Colors.grey[500], size: 16.sp),
                          SizedBox(width: 4.w),
                          Text(
                            'Tangalle Road, Tangalle',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 12.sp,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.access_time, color: Colors.grey[500], size: 16.sp),
                          SizedBox(width: 4.w),
                          Text(
                            '$deliveryTimeMin-$deliveryTimeMax mins',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      const Divider(height: 1, color: Color(0xFFF1F2F6)),
                    ],
                  ),
                ),
              ),

              // Category tabs
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: AppTheme.primary,
                    unselectedLabelColor: Colors.grey[500],
                    indicatorColor: AppTheme.primary,
                    indicatorWeight: 3.h,
                    labelStyle: GoogleFonts.outfit(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: GoogleFonts.outfit(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: _categories.map((cat) => Tab(text: cat)).toList(),
                  ),
                ),
              ),

              // Menu Items Lists
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 100.h), // Extra bottom padding for cart bar
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Filter items based on active tab category
                      final activeCategory = _categories[_tabController.index];
                      final categoryItems = _menuItems.where((item) => item['category'] == activeCategory).toList();
                      
                      if (index >= categoryItems.length) return null;
                      
                      final item = categoryItems[index];
                      final qty = _cartItems[item['name']] ?? 0;

                      return MenuItemCard(
                        name: item['name'] as String,
                        description: item['description'] as String,
                        price: item['price'] as int,
                        imageUrl: item['imageUrl'] as String,
                        quantity: qty,
                        onAdd: () => _addToCart(item['name'] as String),
                        onRemove: () => _removeFromCart(item['name'] as String),
                      );
                    },
                    childCount: _menuItems.length, // Upper bound, list builder returns null if out of range
                  ),
                ),
              ),
            ],
          ),

          // Floating Bottom View Cart Bar
          if (totalItems > 0)
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: 24.h,
              child: AnimatedOpacity(
                opacity: totalItems > 0 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: Container(
                  height: 58.h,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              totalItems.toString(),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'LKR $totalPrice',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'View Cart',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20.sp),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Helper delegate for persistent category header tabs
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overrides) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
