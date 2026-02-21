import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import '../providers/fleet_provider.dart';
import '../providers/trip_provider.dart';

class CommandCenterScreen extends StatelessWidget {
  const CommandCenterScreen({super.key});

  Widget _buildKPICard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: color),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fleet = context.watch<FleetProvider>();
    final trip = context.watch<TripProvider>();

    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Command Center')),
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            bool isWide = constraints.maxWidth > 800;
            return GridView.count(
              crossAxisCount: isWide ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildKPICard(
                  'Active Fleet',
                  '${fleet.activeFleetCount}',
                  FluentIcons.transportation,
                  Colors.blue,
                ),
                _buildKPICard(
                  'Maintenance Alerts',
                  '${fleet.maintenanceAlertsCount}',
                  FluentIcons.warning,
                  Colors.orange,
                ),
                _buildKPICard(
                  'Utilization Rate',
                  '${fleet.utilizationRate.toStringAsFixed(1)}%',
                  FluentIcons.pie_single,
                  Colors.green,
                ),
                _buildKPICard(
                  'Pending Cargo',
                  '${trip.pendingCargoCount}',
                  FluentIcons.package,
                  Colors.purple,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 32),
        const Text(
          'Fleet Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Table(
          border: TableBorder.all(color: Colors.grey[100]),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(1),
          },
          children: [
            const TableRow(
              decoration: BoxDecoration(color: Color(0x11000000)),
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Vehicle',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'License',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            ...fleet.vehicles.map(
              (v) => TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(v.name),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(v.licensePlate),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(v.status.name.toUpperCase()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
