import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:fleet_flow/features/driver/presentation/provider/driver_provider.dart';
import 'package:fleet_flow/features/driver/data/models/driver_model.dart';
import 'package:fleet_flow/features/auth/presentation/provider/auth_provider.dart';
import 'package:fleet_flow/common/widgets/app_toast.dart';

class DriverProfilesScreen extends StatefulWidget {
  const DriverProfilesScreen({super.key});

  @override
  State<DriverProfilesScreen> createState() => _DriverProfilesScreenState();
}

class _DriverProfilesScreenState extends State<DriverProfilesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverProvider>().loadDrivers();
    });
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final licenseNumberCtrl = TextEditingController();
    DateTime? selectedDate = DateTime.now().add(const Duration(days: 365));

    final Set<String> selectedCategories = {'VAN', 'TRUCK'};

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
                  InfoLabel(
                    label: 'Name',
                    child: TextBox(
                      controller: nameCtrl,
                      placeholder: 'Enter driver name',
                    ),
                  ),
                  const SizedBox(height: 12),
                  InfoLabel(
                    label: 'Email',
                    child: TextBox(
                      controller: emailCtrl,
                      placeholder: 'Enter driver email',
                    ),
                  ),
                  const SizedBox(height: 12),
                  InfoLabel(
                    label: 'Phone number',
                    child: TextBox(
                      controller: phoneCtrl,
                      placeholder: 'Enter driver phone number',
                    ),
                  ),
                  const SizedBox(height: 12),
                  InfoLabel(
                    label: 'License number',
                    child: TextBox(
                      controller: licenseNumberCtrl,
                      placeholder: 'Enter license number',
                    ),
                  ),
                  const SizedBox(height: 12),
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
                  child: context.watch<DriverProvider>().isLoading
                      ? const ProgressRing(strokeWidth: 2.0)
                      : const Text('Add'),
                  onPressed: () async {
                    if (nameCtrl.text.isEmpty ||
                        emailCtrl.text.isEmpty ||
                        phoneCtrl.text.isEmpty ||
                        licenseNumberCtrl.text.isEmpty) {
                      AppToast.error("All fields must be filled");
                      return;
                    }

                    final data = {
                      "name": nameCtrl.text,
                      "email": emailCtrl.text,
                      "phone": phoneCtrl.text,
                      "licenseNumber": licenseNumberCtrl.text,
                      "licenseExpiryDate": selectedDate?.toIso8601String(),
                      "licenseCategories": selectedCategories.toList(),
                    };

                    final provider = context.read<DriverProvider>();
                    final nav = Navigator.of(context);
                    final success = await provider.addDriver(data);

                    if (success) {
                      AppToast.success("Driver created successfully");
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
    final auth = context.watch<AuthProvider>();
    final driverProvider = context.watch<DriverProvider>();
    final canEdit =
        auth.role == UserRole.fleetManager ||
        auth.role == UserRole.safetyOfficer;

    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: const Text('Driver Profiles & Safety'),
        commandBar: canEdit
            ? FilledButton(
                onPressed: () => _showAddDialog(context),
                child: const Text('+ Add Driver'),
              )
            : null,
      ),
      children: [
        if (driverProvider.isLoading && driverProvider.drivers.isEmpty)
          const Center(child: ProgressRing())
        else if (driverProvider.drivers.isEmpty)
          const Center(child: Text("No drivers found."))
        else
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth > 1000
                        ? constraints.maxWidth
                        : 1000,
                  ),
                  child: Table(
                    border: TableBorder.all(color: Colors.grey[100]),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(2),
                      4: FlexColumnWidth(1),
                      5: FlexColumnWidth(2),
                      6: FlexColumnWidth(2),
                    },
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Color(0x11000000),
                        ),
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Name',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Email',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'License Number',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'License Expiry',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Score',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Current Status',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (canEdit)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Set Status',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                        ],
                      ),
                      ...driverProvider.drivers.map((DriverModel d) {
                        final isExpired = DateTime.now().isAfter(
                          d.licenseExpiryDate,
                        );
                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(d.name),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(d.email),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(d.licenseNumber),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${d.licenseExpiryDate.toLocal()}'.split(
                                  ' ',
                                )[0],
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
                              child: Text(d.status),
                            ),
                            if (canEdit)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DropDownButton(
                                  title: const Text('Change'),
                                  items:
                                      [
                                            'AVAILABLE',
                                            'ON_TRIP',
                                            'OFF_DUTY',
                                            'SUSPENDED',
                                          ]
                                          .map(
                                            (s) => MenuFlyoutItem(
                                              text: Text(s),
                                              onPressed: () {
                                                // TODO: Call proper `/api/drivers/status` endpoint when available.
                                                // For now modify local state.
                                                driverProvider
                                                    .updateDriverStatusLocal(
                                                      d.id,
                                                      s,
                                                    );
                                              },
                                            ),
                                          )
                                          .toList(),
                                ),
                              )
                            else
                              const SizedBox.shrink(),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
