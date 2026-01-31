import '../../pages/splash/splash_page.dart';
import '../../pages/home/home_page.dart';
import '../../pages/admin/auth/login_screen.dart';
import '../../pages/admin/dashboard/main_navigation.dart';

class AppRoutes {
  static final routes = {
    '/': (context) => const SplashPage(),
    '/home': (context) => const HomePage(),
    '/login': (context) => const LoginScreen(),
    '/admin': (context) => const MainNavigation(),
  };
}
