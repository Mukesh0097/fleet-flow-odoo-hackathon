import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:fleet_flow/features/fleet/presentation/provider/fleet_provider.dart';
import 'package:fleet_flow/features/fleet/data/models/vehicle_model.dart';

class MaintenanceLogsScreen extends StatefulWidget {
  const MaintenanceLogsScreen({super.key});

  @override
  State<MaintenanceLogsScreen> createState() => _MaintenanceLogsScreenState();
}

class _MaintenanceLogsScreenState extends State<MaintenanceLogsScreen> {
  void _showAddDialog(BuildContext context) {
    final fleet = context.read<FleetProvider>();
    VehicleModel? selectedVehicle;
    final descCtrl = TextEditingController();
    final costCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ContentDialog(
              title: const Text('Log Maintenance'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ComboBox<VehicleModel>(
                    placeholder: const Text('Select Vehicle'),
                    isExpanded: true,
                    value: selectedVehicle,
                    items: fleet.vehicles
                        .map((v) => ComboBoxItem(value: v, child: Text(v.name)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          selectedVehicle = v;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  TextBox(
                    controller: descCtrl,
                    placeholder: 'Description (e.g. Oil Change)',
                  ),
                  const SizedBox(height: 8),
                  TextBox(controller: costCtrl, placeholder: 'Cost (\$)'),
                ],
              ),
              actions: [
                Button(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                FilledButton(
                  child: const Text('Log Service'),
                  onPressed: () {
                    if (selectedVehicle == null) return;
                    fleet.addMaintenanceLog(
                      MaintenanceLog(
                        selectedVehicle!.id,
                        descCtrl.text,
                        double.tryParse(costCtrl.text) ?? 0,
                        DateTime.now(),
                      ),
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fleet = context.watch<FleetProvider>();

    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: const Text('Maintenance & Service Logs'),
        commandBar: FilledButton(
          onPressed: () => _showAddDialog(context),
          child: const Text('+ Log Maintenance'),
        ),
      ),
      children: [
        Table(
          border: TableBorder.all(color: Colors.grey[100]),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(3),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(2),
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
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Cost',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Date',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            ...fleet.maintenanceLogs.map((log) {
              final v = fleet.vehicles.firstWhere((e) => e.id == log.vehicleId);
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(v.name),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(log.description),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('\$${log.cost.toStringAsFixed(2)}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${log.date.toLocal()}'.split(' ')[0]),
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
