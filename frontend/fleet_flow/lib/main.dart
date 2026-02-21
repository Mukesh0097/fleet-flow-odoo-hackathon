import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

import 'package:fleet_flow/features/auth/presentation/provider/auth_provider.dart';
import 'package:fleet_flow/features/fleet/presentation/provider/fleet_provider.dart';
import 'package:fleet_flow/features/driver/presentation/provider/driver_provider.dart';
import 'package:fleet_flow/features/trip/presentation/provider/trip_provider.dart';
import 'package:fleet_flow/features/users/presentation/provider/user_provider.dart';
import 'package:fleet_flow/route_generator.dart';
import 'package:fleet_flow/core/themes/app_theme.dart';

import 'package:fleet_flow/core/services/storage_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageServices.init();
  runApp(const FleetFlowApp());
}

class FleetFlowApp extends StatefulWidget {
  const FleetFlowApp({super.key});

  @override
  State<FleetFlowApp> createState() => _FleetFlowAppState();
}

class _FleetFlowAppState extends State<FleetFlowApp> {
  late final AuthProvider _authProvider;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    _authProvider.checkAuthStatus();
    _appRouter = AppRouter(_authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider(create: (_) => FleetProvider()),
        ChangeNotifierProvider(create: (_) => DriverProvider()),
        ChangeNotifierProvider(create: (_) => TripProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: FluentApp.router(
        title: 'FleetFlow',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routeInformationProvider: _appRouter.router.routeInformationProvider,
        routeInformationParser: _appRouter.router.routeInformationParser,
        routerDelegate: _appRouter.router.routerDelegate,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
