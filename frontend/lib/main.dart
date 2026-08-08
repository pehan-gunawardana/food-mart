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
            BlocProvider<RestaurantCubit>(
              create: (context) => RestaurantCubit(RestaurantRepository())..fetchRestaurants(),
            ),
            BlocProvider<CartCubit>(
              create: (context) => CartCubit(),
            ),
            BlocProvider<OrderCubit>(
              create: (context) => OrderCubit(OrderRepository()),
            ),
          ],
          child: MaterialApp(
            title: 'FoodMart',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            initialRoute: AppRouter.initialRoute,
            onGenerateRoute: AppRouter.onGenerateRoute,
          ),
        );
      },
    );
  }
}
