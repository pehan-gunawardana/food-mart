import 'package:flutter/material.dart';
import '../../features/customer/presentation/role_selection_screen.dart';
import '../../features/customer/presentation/screens/home_screen.dart';
import '../../features/vendor/presentation/vendor_home_screen.dart';
import '../../features/rider/presentation/rider_home_screen.dart';

class AppRouter {
  static const String initialRoute = '/';
  static const String customerHome = '/customer/home';
  static const String vendorHome = '/vendor/home';
  static const String riderHome = '/rider/home';

  static Map<String, WidgetBuilder> get routes {
    return {
      initialRoute: (context) => const RoleSelectionScreen(),
      customerHome: (context) => const HomeScreen(),
      vendorHome: (context) => const VendorHomeScreen(),
      riderHome: (context) => const RiderHomeScreen(),
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
