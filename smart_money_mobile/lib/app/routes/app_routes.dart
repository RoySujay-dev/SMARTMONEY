import 'package:flutter/material.dart';
import 'package:smart_money_mobile/features/auth/presentation/screens/register_screen.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/browsing/data/models/category.dart';
import '../../features/browsing/presentation/screens/categories_screen.dart';
import '../../features/browsing/presentation/screens/category_stores_screen.dart';
import '../../features/browsing/presentation/screens/offer_details_screen.dart';
import '../../features/browsing/presentation/screens/offers_screen.dart';
import '../../features/browsing/presentation/screens/search_screen.dart';
import '../../features/browsing/presentation/screens/store_details_screen.dart';
import '../../features/browsing/presentation/screens/stores_screen.dart';
import '../../features/shell/presentation/screens/main_shell.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import 'route_names.dart';
import '../../features/profile/presentation/screens/profile_setup_screen.dart';

class AppRoutes {
  AppRoutes._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case RouteNames.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case RouteNames.dashboard:
        return MaterialPageRoute(builder: (_) => const MainShell());

      case RouteNames.profile:
        return MaterialPageRoute(builder: (_) => const ProfileSetupScreen());

      case RouteNames.profileSetup:
        return MaterialPageRoute(builder: (_) => const ProfileSetupScreen());

      case RouteNames.categories:
        return MaterialPageRoute(builder: (_) => const CategoriesScreen());

      case RouteNames.categoryStores:
        final category = settings.arguments;
        if (category is! Category) {
          return _invalidArgumentsRoute(settings.name);
        }
        return MaterialPageRoute(
          builder: (_) => CategoryStoresScreen(category: category),
        );

      case RouteNames.stores:
        return MaterialPageRoute(builder: (_) => const StoresScreen());

      case RouteNames.storeDetails:
        final slug = settings.arguments;
        if (slug is! String || slug.isEmpty) {
          return _invalidArgumentsRoute(settings.name);
        }
        return MaterialPageRoute(
          builder: (_) => StoreDetailsScreen(storeSlug: slug),
        );

      case RouteNames.offers:
        return MaterialPageRoute(builder: (_) => const OffersScreen());

      case RouteNames.offerDetails:
        final slug = settings.arguments;
        if (slug is! String || slug.isEmpty) {
          return _invalidArgumentsRoute(settings.name);
        }
        return MaterialPageRoute(
          builder: (_) => OfferDetailsScreen(offerSlug: slug),
        );

      case RouteNames.search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }

  static Route<dynamic> _invalidArgumentsRoute(String? routeName) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text('Unable to open "${routeName ?? 'screen'}".'),
        ),
      ),
    );
  }
}
