import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import '../providers/driver_provider.dart';

class DriverProfilesScreen extends StatefulWidget {
  const DriverProfilesScreen({super.key});

  @override
  State<DriverProfilesScreen> createState() => _DriverProfilesScreenState();
}

class _DriverProfilesScreenState extends State<DriverProfilesScreen> {
  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    DateTime? selectedDate = DateTime.now().add(const Duration(days: 365));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ContentDialog(
              title: const Text('Add Driver'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextBox(controller: nameCtrl, placeholder: 'Driver Name'),
                  const SizedBox(height: 8),
                  DatePicker(
                    header: 'License Expiry',
                    selected: selectedDate,
                    onChanged: (v) => setState(() => selectedDate = v),
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
                    final provider = context.read<DriverProvider>();
                    provider.addDriver(
                      Driver(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameCtrl.text,
                        licenseExpiry: selectedDate ?? DateTime.now(),
                        allowedVehicleTypes: ['van', 'truck', 'bike'],
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
    final drivers = context.watch<DriverProvider>();

    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: const Text('Driver Profiles & Safety'),
        commandBar: FilledButton(
          onPressed: () => _showAddDialog(context),
          child: const Text('+ Add Driver'),
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
                    'License Expiry',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Score',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Current Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Set Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            ...drivers.drivers.map((d) {
              final isExpired = !d.isLicenseValid;
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(d.name),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${d.licenseExpiry.toLocal()}'.split(' ')[0],
                      style: TextStyle(
                        color: isExpired ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${d.safetyScore}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(d.status.name.toUpperCase()),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropDownButton(
                      title: const Text('Change'),
                      items: DriverStatus.values
                          .map(
                            (s) => MenuFlyoutItem(
                              text: Text(s.name.toUpperCase()),
                              onPressed: () =>
                                  drivers.updateDriverStatus(d.id, s),
                            ),
                          )
                          .toList(),
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
