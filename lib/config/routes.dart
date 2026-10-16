import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../screens/screen.dart';

class Routes {
  static const String home = '/home';
  static const String pickUp = '/pick_up';
  static const String roles = '/roles';
  static const String activity = '/activity';
  static const String tripProgress = '/trip_progress';
  static const String driver = '/driver';
  static const String admin = '/admin';
  static const String groceries = '/groceries';
  static const String delivery = '/delivery';
  static const String food = '/food';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const HomePage());

      case pickUp:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const PickUpPage());

      case roles:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const RolesPage());

      case activity:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const ActivityPage());

      case tripProgress:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const TripProgressPage());

      case driver:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const DriverHomePage());

      case admin:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const AdminDashboardPage());

      case groceries:
        return MaterialPageRoute(
            settings: settings, builder: (_) => GroceriesPage(api: ApiService.forWeb()));

      case delivery:
        return MaterialPageRoute(
            settings: settings, builder: (_) => DeliveryPage(api: ApiService.forWeb()));

      case food:
        return MaterialPageRoute(
            settings: settings, builder: (_) => FoodPage(api: ApiService.forWeb()));

      case '/':
      default:
        return MaterialPageRoute(
            settings: settings,
            builder: (_) => Scaffold(
                  appBar: AppBar(
                    title: const Text('Routes'),
                    centerTitle: true, // Judul di tengah
                  ),
                  body: const Center(
                    child: Text('Routes Not Found'),
                  ),
                ));
    }
  }
}
