import 'package:flutter/foundation.dart';
import 'package:fleet_flow/features/driver/data/models/driver_model.dart';
import 'package:fleet_flow/features/driver/data/repository/driver_repository.dart';

class DriverProvider extends ChangeNotifier {
  final DriverRepository _driverRepository;

  List<DriverModel> _drivers = [];
  bool _isLoading = false;
  String? _errorMessage;

  DriverProvider({DriverRepository? driverRepository})
    : _driverRepository = driverRepository ?? DriverRepository();

  List<DriverModel> get drivers => _drivers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<DriverModel> get availableDrivers => _drivers
      .where(
        (d) =>
            (d.status == 'AVAILABLE' || d.status == 'OFF_DUTY') &&
            DateTime.now().isBefore(d.licenseExpiryDate),
      )
      .toList();

  Future<void> loadDrivers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _driverRepository.getDrivers();

    if (result.isSuccess && result.data != null) {
      _drivers = result.data!;
    } else {
      _errorMessage = result.error ?? "Failed to load drivers";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addDriver(Map<String, dynamic> driverData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _driverRepository.createDriver(driverData);

    _isLoading = false;

    if (result.isSuccess && result.data != null) {
      // Opt to reload or insert manually.
      _drivers.insert(0, result.data!);
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.error ?? "Failed to register driver";
      notifyListeners();
      return false;
    }
  }

  // Example method structure for a future update status endpoint (not provided yet)
  void updateDriverStatusLocal(String driverId, String newStatus) {
    final index = _drivers.indexWhere((d) => d.id == driverId);
    if (index != -1) {
      // Since DriverModel properties are final, we replace the object in the list
      final oldDriver = _drivers[index];
      final updatedDriver = DriverModel(
        id: oldDriver.id,
        name: oldDriver.name,
        email: oldDriver.email,
        phone: oldDriver.phone,
        status: newStatus,
        licenseNumber: oldDriver.licenseNumber,
        licenseExpiryDate: oldDriver.licenseExpiryDate,
        licenseCategories: oldDriver.licenseCategories,
        safetyScore: oldDriver.safetyScore,
        totalTrips: oldDriver.totalTrips,
        completedTrips: oldDriver.completedTrips,
        createdAt: oldDriver.createdAt,
        updatedAt: oldDriver.updatedAt,
      );
      _drivers[index] = updatedDriver;
      notifyListeners();
    }
  }
}
