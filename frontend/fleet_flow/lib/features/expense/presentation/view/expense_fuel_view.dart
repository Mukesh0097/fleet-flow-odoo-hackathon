import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:fleet_flow/features/fleet/presentation/provider/fleet_provider.dart';

class ExpenseFuelScreen extends StatefulWidget {
  const ExpenseFuelScreen({super.key});

  @override
  State<ExpenseFuelScreen> createState() => _ExpenseFuelScreenState();
}

class _ExpenseFuelScreenState extends State<ExpenseFuelScreen> {
  void _showAddDialog(BuildContext context) {
    final fleet = context.read<FleetProvider>();
    Vehicle? selectedVehicle;
    final litersCtrl = TextEditingController();
    final costCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ContentDialog(
              title: const Text('Log Fuel'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ComboBox<Vehicle>(
                    placeholder: const Text('Select Vehicle'),
                    isExpanded: true,
                    value: selectedVehicle,
                    items: fleet.vehicles
                        .map((v) => ComboBoxItem(value: v, child: Text(v.name)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null)
                        setState(() {
                          selectedVehicle = v;
                        });
                    },
                  ),
                  const SizedBox(height: 8),
                  TextBox(controller: litersCtrl, placeholder: 'Liters'),
                  const SizedBox(height: 8),
                  TextBox(controller: costCtrl, placeholder: 'Total Cost (\$)'),
                ],
              ),
              actions: [
                Button(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                FilledButton(
                  child: const Text('Log'),
                  onPressed: () {
                    if (selectedVehicle == null) return;
                    fleet.addFuelLog(
                      FuelLog(
                        selectedVehicle!.id,
                        double.tryParse(litersCtrl.text) ?? 0,
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
        title: const Text('Expense & Fuel Logs'),
        commandBar: FilledButton(
          onPressed: () => _showAddDialog(context),
          child: const Text('+ Log Fuel'),
        ),
      ),
      children: [
        Table(
          border: TableBorder.all(color: Colors.grey[100]),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(2),
            4: FlexColumnWidth(2),
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
                    'Liters',
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
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Total Op Cost',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            ...fleet.fuelLogs.map((log) {
              final v = fleet.vehicles.firstWhere((e) => e.id == log.vehicleId);
              final totalOp = fleet.getTotalOperatingCost(v.id);
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(v.name),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${log.liters} L'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('\$${log.cost.toStringAsFixed(2)}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${log.date.toLocal()}'.split(' ')[0]),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('\$${totalOp.toStringAsFixed(2)}'),
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
