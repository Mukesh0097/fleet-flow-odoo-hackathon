import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import '../providers/fleet_provider.dart';

class AnalyticsReportsScreen extends StatelessWidget {
  const AnalyticsReportsScreen({super.key});

  void _showExportSuccess(BuildContext context) {
    displayInfoBar(
      context,
      builder: (context, close) {
        return InfoBar(
          title: const Text('Export Successful'),
          content: const Text('Report has been saved to your downloads.'),
          severity: InfoBarSeverity.success,
          action: IconButton(
            icon: const Icon(FluentIcons.clear),
            onPressed: close,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fleet = context.watch<FleetProvider>();
    final efficiency = fleet.fleetFuelEfficiency;

    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: const Text('Operational Analytics & Financials'),
        commandBar: FilledButton(
          onPressed: () => _showExportSuccess(context),
          child: const Text('Export CSV/PDF'),
        ),
      ),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall Fleet Fuel Efficiency',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '${efficiency.toStringAsFixed(2)} km/L',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Vehicle ROI',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Formula: (Mock Revenue - Operating Cost) / Mock Acquisition Cost',
        ),
        const SizedBox(height: 16),
        Table(
          border: TableBorder.all(color: Colors.grey[100]),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(2),
            4: FlexColumnWidth(2),
          },
          children: [
            TableRow(
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
                    'Est. Revenue',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Operating Cost',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Acquisition Cost',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'ROI (%)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            ...fleet.vehicles.map((v) {
              final opCost = fleet.getTotalOperatingCost(v.id);
              final estRevenue = v.odometer * 0.5; // Mock: $0.5 per km
              const acqCost = 30000.0; // Mock 30k
              final roi = acqCost > 0
                  ? ((estRevenue - opCost) / acqCost) * 100
                  : 0.0;

              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(v.name),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('\$${estRevenue.toStringAsFixed(2)}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('\$${opCost.toStringAsFixed(2)}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('\$${acqCost.toStringAsFixed(0)}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${roi.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: roi >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }
}
