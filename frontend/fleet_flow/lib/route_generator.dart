import 'package:go_router/go_router.dart';
import 'package:fleet_flow/features/auth/presentation/provider/auth_provider.dart';
import 'package:fleet_flow/features/auth/presentation/view/login_view.dart';
import 'package:fleet_flow/features/dashboard/presentation/view/main_navigation_view.dart';
import 'package:fleet_flow/core/constants/app_routes.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: authProvider,
    redirect: (context, state) {
      final bool isAuthenticated = authProvider.isAuthenticated;
      final bool isLoggingIn = state.uri.path == AppRoutes.login;

      if (!isAuthenticated && !isLoggingIn) {
        return AppRoutes.login;
      }

      if (isAuthenticated && isLoggingIn) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const MainNavigationView(),
      ),
    ],
  );
}
