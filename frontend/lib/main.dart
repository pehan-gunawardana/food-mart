import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'features/customer/data/repositories/restaurant_repository.dart';
import 'features/customer/data/repositories/order_repository.dart';
import 'features/customer/presentation/bloc/restaurant_cubit.dart';
import 'features/customer/presentation/bloc/cart_cubit.dart';
import 'features/customer/presentation/bloc/order_cubit.dart';
import 'features/customer/presentation/bloc/order_history_cubit.dart';
import 'features/vendor/presentation/bloc/vendor_orders_cubit.dart';
import 'features/vendor/presentation/bloc/vendor_menu_cubit.dart';
import 'features/vendor/data/repositories/menu_repository.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/customer/presentation/screens/home_screen.dart';
import 'features/vendor/presentation/screens/vendor_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Responsive layout base design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>(
              create: (context) => AuthCubit(AuthRepository())..checkAuthStatus(),
            ),
            BlocProvider<RestaurantCubit>(
              create: (context) => RestaurantCubit(RestaurantRepository())..fetchRestaurants(),
            ),
            BlocProvider<CartCubit>(
              create: (context) => CartCubit(),
            ),
            BlocProvider<OrderCubit>(
              create: (context) => OrderCubit(OrderRepository()),
            ),
            BlocProvider<OrderHistoryCubit>(
              create: (context) => OrderHistoryCubit(OrderRepository()),
            ),
            BlocProvider<VendorOrdersCubit>(
              create: (context) => VendorOrdersCubit(OrderRepository()),
            ),
            BlocProvider<VendorMenuCubit>(
              create: (context) => VendorMenuCubit(MenuRepository()),
            ),
          ],
          child: MaterialApp(
            title: 'FoodMart',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            home: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                if (state is Authenticated) {
                  if (state.user.role.toUpperCase() == 'VENDOR') {
                    return const VendorHomeScreen();
                  }
                  return const HomeScreen();
                } else if (state is Unauthenticated || state is AuthError) {
                  return const LoginScreen();
                }
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  ),
                );
              },
            ),
            onGenerateRoute: AppRouter.onGenerateRoute,
          ),
        );
      },
    );
  }
}
