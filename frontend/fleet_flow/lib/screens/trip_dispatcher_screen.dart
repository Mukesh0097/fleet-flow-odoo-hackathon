import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import '../providers/fleet_provider.dart';
import '../providers/driver_provider.dart';
import '../providers/trip_provider.dart';

class TripDispatcherScreen extends StatefulWidget {
  const TripDispatcherScreen({super.key});

  @override
  State<TripDispatcherScreen> createState() => _TripDispatcherScreenState();
}

class _TripDispatcherScreenState extends State<TripDispatcherScreen> {
  void _showAddDialog(BuildContext context) {
    final fleet = context.read<FleetProvider>();
    final drivers = context.read<DriverProvider>();
    final trips = context.read<TripProvider>();

    final availableVehicles = fleet.availableVehicles;
    final availableDrivers = drivers.availableDrivers;

    Vehicle? selectedVehicle;
    Driver? selectedDriver;
    final weightCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ContentDialog(
              title: const Text('Dispatch New Trip'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ComboBox<Vehicle>(
                    placeholder: const Text('Select Vehicle'),
                    isExpanded: true,
                    value: selectedVehicle,
                    items: availableVehicles
                        .map(
                          (v) => ComboBoxItem(
                            value: v,
                            child: Text(
                              '${v.name} (${v.licensePlate} - Max ${v.maxLoadCapacity}kg)',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null)
                        setState(() {
                          selectedVehicle = v;
                        });
                    },
                  ),
                  const SizedBox(height: 8),
                  ComboBox<Driver>(
                    placeholder: const Text('Select Driver'),
                    isExpanded: true,
                    value: selectedDriver,
                    items: availableDrivers
                        .map((d) => ComboBoxItem(value: d, child: Text(d.name)))
                        .toList(),
                    onChanged: (d) {
                      if (d != null)
                        setState(() {
                          selectedDriver = d;
                        });
                    },
                  ),
                  const SizedBox(height: 8),
                  TextBox(
                    controller: weightCtrl,
                    placeholder: 'Cargo Weight (kg)',
                  ),
                ],
              ),
              actions: [
                Button(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                FilledButton(
                  child: const Text('Dispatch'),
                  onPressed: () {
                    if (selectedVehicle == null || selectedDriver == null)
                      return;

                    final weight = double.tryParse(weightCtrl.text) ?? 0;
                    final error = trips.validateAndCreateTrip(
                      driverId: selectedDriver!.id,
                      vehicle: selectedVehicle!,
                      cargoWeight: weight,
                    );

                    if (error != null) {
                      displayInfoBar(
                        context,
                        builder: (context, close) {
                          return InfoBar(
                            title: const Text('Validation Error'),
                            content: Text(error),
                            severity: InfoBarSeverity.error,
                          );
                        },
                      );
                    } else {
                      fleet.updateVehicleStatus(
                        selectedVehicle!.id,
                        VehicleStatus.onTrip,
                      );
                      drivers.updateDriverStatus(
                        selectedDriver!.id,
                        DriverStatus.onTrip,
                      );
                      Navigator.pop(context);
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
    final trips = context.watch<TripProvider>();
    final fleet = context.watch<FleetProvider>();
    final drivers = context.watch<DriverProvider>();

    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: const Text('Trip Dispatcher'),
        commandBar: FilledButton(
          onPressed: () => _showAddDialog(context),
          child: const Text('+ Dispatch Trip'),
        ),
      ),
      children: [
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
            const TableRow(
              decoration: BoxDecoration(color: Color(0x11000000)),
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Trip ID',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
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
                    'Driver',
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
            ...trips.trips.map((t) {
              final v = fleet.vehicles.firstWhere(
                (element) => element.id == t.vehicleId,
              );
              final d = drivers.drivers.firstWhere(
                (element) => element.id == t.driverId,
              );
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(t.id),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(v.name),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(d.name),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(t.status.name.toUpperCase()),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: t.status == TripStatus.dispatched
                        ? Button(
                            child: const Text('Complete'),
                            onPressed: () {
                              trips.completeTrip(t.id);
                              fleet.updateVehicleStatus(
                                v.id,
                                VehicleStatus.available,
                              );
                              drivers.updateDriverStatus(
                                d.id,
                                DriverStatus.available,
                              );
                            },
                          )
                        : const SizedBox.shrink(),
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
