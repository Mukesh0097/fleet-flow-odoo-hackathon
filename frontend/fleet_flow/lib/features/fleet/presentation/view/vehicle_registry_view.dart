import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:fleet_flow/features/fleet/presentation/provider/fleet_provider.dart';

class VehicleRegistryScreen extends StatefulWidget {
  const VehicleRegistryScreen({super.key});

  @override
  State<VehicleRegistryScreen> createState() => _VehicleRegistryScreenState();
}

class _VehicleRegistryScreenState extends State<VehicleRegistryScreen> {
  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final licenseCtrl = TextEditingController();
    final loadCtrl = TextEditingController();
    final odometerCtrl = TextEditingController();
    VehicleType selectedType = VehicleType.van;

    showDialog(
      context: context,
      builder: (context) {
        return ContentDialog(
          title: const Text('Add Vehicle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextBox(controller: nameCtrl, placeholder: 'Name/Model'),
              const SizedBox(height: 8),
              TextBox(controller: licenseCtrl, placeholder: 'License Plate'),
              const SizedBox(height: 8),
              TextBox(
                controller: loadCtrl,
                placeholder: 'Max Load Capacity (kg)',
              ),
              const SizedBox(height: 8),
              TextBox(controller: odometerCtrl, placeholder: 'Odometer (km)'),
              const SizedBox(height: 8),
              ComboBox<VehicleType>(
                value: selectedType,
                items: VehicleType.values
                    .map((e) => ComboBoxItem(value: e, child: Text(e.name)))
                    .toList(),
                onChanged: (v) {
                  if (v != null)
                    setState(() {
                      selectedType = v;
                    });
                },
              ),
            ],
          ),
          actions: [
            Button(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            FilledButton(
              child: const Text('Add'),
              onPressed: () {
                final provider = context.read<FleetProvider>();
                provider.addVehicle(
                  Vehicle(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameCtrl.text,
                    type: selectedType,
                    licensePlate: licenseCtrl.text,
                    maxLoadCapacity: double.tryParse(loadCtrl.text) ?? 0,
                    odometer: double.tryParse(odometerCtrl.text) ?? 0,
                  ),
                );
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fleet = context.watch<FleetProvider>();

    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: const Text('Vehicle Registry'),
        commandBar: FilledButton(
          onPressed: () => _showAddDialog(context),
          child: const Text('+ Add Vehicle'),
        ),
      ),
      children: [
        Table(
          border: TableBorder.all(color: Colors.grey[100]),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(2),
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
                    'Name',
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
                    'Type',
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
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Actions',
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
                    child: Text(v.type.name.toUpperCase()),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(v.status.name.toUpperCase()),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ToggleSwitch(
                      checked: v.status == VehicleStatus.retired,
                      content: const Text('Retired'),
                      onChanged: (retired) {
                        fleet.updateVehicleStatus(
                          v.id,
                          retired
                              ? VehicleStatus.retired
                              : VehicleStatus.available,
                        );
                      },
                    ),
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
