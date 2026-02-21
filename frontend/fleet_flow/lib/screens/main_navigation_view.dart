import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'command_center_screen.dart';
import 'vehicle_registry_screen.dart';
import 'trip_dispatcher_screen.dart';
import 'maintenance_logs_screen.dart';
import 'expense_fuel_screen.dart';
import 'driver_profiles_screen.dart';
import 'analytics_reports_screen.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int topIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return NavigationView(
      appBar: NavigationAppBar(
        title: const Text(
          'FleetFlow',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        actions: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Role: ${auth.role?.name ?? 'Unknown'}'),
                const SizedBox(width: 16),
                Button(
                  onPressed: () => context.read<AuthProvider>().logout(),
                  child: const Text('Logout'),
                ),
              ],
            ),
          ),
        ),
      ),
      pane: NavigationPane(
        selected: topIndex,
        onChanged: (index) => setState(() => topIndex = index),
        displayMode: PaneDisplayMode.auto,
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.view_dashboard),
            title: const Text('Command Center'),
            body: const CommandCenterScreen(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.transportation),
            title: const Text('Vehicle Registry'),
            body: const VehicleRegistryScreen(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.build_queue),
            title: const Text('Trip Dispatcher'),
            body: const TripDispatcherScreen(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text('Maintenance Logs'),
            body: const MaintenanceLogsScreen(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.payment_card),
            title: const Text('Expense & Fuel Logs'),
            body: const ExpenseFuelScreen(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.contact),
            title: const Text('Driver Profiles'),
            body: const DriverProfilesScreen(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.bar_chart4),
            title: const Text('Analytics & Reports'),
            body: const AnalyticsReportsScreen(),
          ),
        ],
      ),
    );
  }
}
