import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/fleet_provider.dart';
import 'providers/driver_provider.dart';
import 'providers/trip_provider.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
