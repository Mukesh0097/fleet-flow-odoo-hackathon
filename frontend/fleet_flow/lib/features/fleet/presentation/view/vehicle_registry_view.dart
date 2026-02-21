import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:fleet_flow/features/fleet/presentation/provider/fleet_provider.dart';
import 'package:fleet_flow/features/auth/presentation/provider/auth_provider.dart';
import 'package:fleet_flow/common/widgets/app_toast.dart';

class VehicleRegistryScreen extends StatefulWidget {
  const VehicleRegistryScreen({super.key});

  @override
  State<VehicleRegistryScreen> createState() => _VehicleRegistryScreenState();
}

class _VehicleRegistryScreenState extends State<VehicleRegistryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FleetProvider>().loadVehicles();
    });
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final licenseCtrl = TextEditingController();
    final loadCtrl = TextEditingController();
    final odometerCtrl = TextEditingController();
    String selectedType = 'VAN';
    final vehicleTypes = ['TRUCK', 'VAN', 'BIKE', 'CAR'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ContentDialog(
              title: const Text('Add Vehicle'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextBox(controller: nameCtrl, placeholder: 'Name/Model'),
                  const SizedBox(height: 8),
                  TextBox(
                    controller: licenseCtrl,
                    placeholder: 'License Plate',
                  ),
                  const SizedBox(height: 8),
                  TextBox(
                    controller: loadCtrl,
                    placeholder: 'Max Load Capacity (kg)',
                  ),
                  const SizedBox(height: 8),
                  TextBox(
                    controller: odometerCtrl,
                    placeholder: 'Odometer (km)',
                  ),
                  const SizedBox(height: 8),
                  ComboBox<String>(
                    value: selectedType,
                    items: vehicleTypes
                        .map((e) => ComboBoxItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          selectedType = v;
                        });
                      }
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
                  child: context.watch<FleetProvider>().isLoading
                      ? const ProgressRing(strokeWidth: 2.0)
                      : const Text('Add'),
                  onPressed: () async {
                    if (nameCtrl.text.isEmpty || licenseCtrl.text.isEmpty) {
                      AppToast.error("Name and License are required");
                      return;
                    }

                    final provider = context.read<FleetProvider>();
                    final nav = Navigator.of(context);

                    final success = await provider.addVehicle({
                      "name": nameCtrl.text,
                      "model":
                          nameCtrl.text, // Same as name for simplistic input
                      "licensePlate": licenseCtrl.text,
                      "vehicleType": selectedType,
                      "maxCapacityKg": double.tryParse(loadCtrl.text) ?? 0,
                    });

                    if (success) {
                      AppToast.success("Vehicle created successfully");
                      nav.pop();
                    }
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
    final auth = context.watch<AuthProvider>();
    final canEdit = auth.role == UserRole.fleetManager;

    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: const Text('Vehicle Registry'),
        commandBar: canEdit
            ? FilledButton(
                onPressed: () => _showAddDialog(context),
                child: const Text('+ Add Vehicle'),
              )
            : null,
      ),
      children: [
        if (fleet.isLoading && fleet.vehicles.isEmpty)
          const Center(child: ProgressRing())
        else if (fleet.vehicles.isEmpty)
          const Center(child: Text("No vehicles found."))
        else
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
                      child: Text(v.vehicleType),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(v.status),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: canEdit
                          ? ToggleSwitch(
                              checked: v.status == 'RETIRED' || v.isRetired,
                              content: const Text('Retired'),
                              onChanged: (retired) {
                                fleet.updateVehicleStatusLocal(
                                  v.id,
                                  retired ? 'RETIRED' : 'AVAILABLE',
                                );
                              },
                            )
                          : const SizedBox.shrink(),
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
