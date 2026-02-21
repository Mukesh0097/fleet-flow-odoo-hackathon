import 'package:flutter/foundation.dart';

enum DriverStatus { available, onTrip, offDuty, suspended }

class Driver {
  final String id;
  final String name;
  final DateTime licenseExpiry;
  final List<String> allowedVehicleTypes;
  DriverStatus status;
  double safetyScore;

  Driver({
    required this.id,
    required this.name,
    required this.licenseExpiry,
    required this.allowedVehicleTypes,
    this.status = DriverStatus.available,
    this.safetyScore = 100.0,
  });

  bool get isLicenseValid => DateTime.now().isBefore(licenseExpiry);
}

class DriverProvider extends ChangeNotifier {
  final List<Driver> _drivers = [
    Driver(
      id: 'd1',
      name: 'Alex',
      licenseExpiry: DateTime.now().add(const Duration(days: 365)),
      allowedVehicleTypes: ['van', 'bike'],
      status: DriverStatus.available,
      safetyScore: 98.5,
    ),
    Driver(
      id: 'd2',
      name: 'Sam',
      licenseExpiry: DateTime.now().subtract(const Duration(days: 10)),
      allowedVehicleTypes: ['truck', 'van'],
      status: DriverStatus.offDuty,
      safetyScore: 85.0,
    ),
  ];

  List<Driver> get drivers => _drivers;
  List<Driver> get availableDrivers => _drivers
      .where((d) => d.status == DriverStatus.available && d.isLicenseValid)
      .toList();

  void addDriver(Driver driver) {
    _drivers.add(driver);
    notifyListeners();
  }

  void updateDriverStatus(String driverId, DriverStatus newStatus) {
    final index = _drivers.indexWhere((d) => d.id == driverId);
    if (index != -1) {
      _drivers[index].status = newStatus;
      notifyListeners();
    }
  }
}
