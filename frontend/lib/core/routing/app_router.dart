import 'package:flutter/material.dart';
import '../../features/customer/presentation/role_selection_screen.dart';
import '../../features/customer/presentation/screens/home_screen.dart';
import '../../features/customer/presentation/screens/restaurant_detail_screen.dart';
import '../../features/vendor/presentation/screens/vendor_home_screen.dart';
import '../../features/rider/presentation/rider_home_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/customer/presentation/screens/location_picker_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';

class AppRouter {
  static const String initialRoute = '/';
  static const String roleSelection = '/role-selection';
  static const String login = '/login';
  static const String register = '/register';
  static const String customerHome = '/customer/home';
  static const String vendorHome = '/vendor/home';
  static const String riderHome = '/rider/home';
  static const String restaurantDetail = '/restaurant/detail';
  static const String locationPicker = '/customer/location-picker';

  static Map<String, WidgetBuilder> get routes {
    return {
      initialRoute: (context) => const SplashScreen(),
      roleSelection: (context) => const RoleSelectionScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      customerHome: (context) => const HomeScreen(),
      vendorHome: (context) => const VendorHomeScreen(),
      riderHome: (context) => const RiderHomeScreen(),
      locationPicker: (context) => const LocationPickerScreen(),
      restaurantDetail: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
        return RestaurantDetailScreen(restaurantArgs: args);
      },
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(
        builder: builder,
        settings: settings,
      );
    }
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        body: Center(
          child: Text('No route defined for ${settings.name}'),
        ),
      ),
    );
  }
}
