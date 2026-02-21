import 'package:flutter/foundation.dart';
import 'package:fleet_flow/features/fleet/data/models/vehicle_model.dart';
import 'package:fleet_flow/features/fleet/data/repository/vehicle_repository.dart';

class FleetProvider extends ChangeNotifier {
  final VehicleRepository _repository;

  FleetProvider({VehicleRepository? repository})
    : _repository = repository ?? VehicleRepository();

  List<VehicleModel> _vehicles = [];
  bool _isLoading = false;
  String? _error;

  List<VehicleModel> get vehicles => _vehicles;
  List<VehicleModel> get availableVehicles =>
      _vehicles.where((v) => v.status == 'AVAILABLE').toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadVehicles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.getVehicles();

    _isLoading = false;
    if (result.isSuccess) {
      _vehicles = result.data ?? [];
    } else {
      _error = result.error;
    }
    notifyListeners();
  }

  Future<bool> addVehicle(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.createVehicle(data);

    if (result.isSuccess && result.data != null) {
      _vehicles.add(result.data!);
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = result.error;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void updateVehicleStatusLocal(String vehicleId, String newStatus) {
    final index = _vehicles.indexWhere((v) => v.id == vehicleId);
    if (index != -1) {
      final old = _vehicles[index];
      // Since VehicleModel fields are final, we can either copyWith or just mutate locally if we change to non-final.
      // But creating a new model is better.
      _vehicles[index] = VehicleModel(
        id: old.id,
        name: old.name,
        model: old.model,
        licensePlate: old.licensePlate,
        vehicleType: old.vehicleType,
        maxCapacityKg: old.maxCapacityKg,
        currentOdometer: old.currentOdometer,
        acquisitionCost: old.acquisitionCost,
        status: newStatus,
        region: old.region,
        isRetired: newStatus == 'RETIRED' || old.isRetired,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // Dashboard KPIs
  int get activeFleetCount =>
      _vehicles.where((v) => v.status == 'ON_TRIP').length;
  int get maintenanceAlertsCount =>
      _vehicles.where((v) => v.status == 'IN_SHOP').length;

  double get utilizationRate {
    if (_vehicles.isEmpty) return 0.0;
    return (activeFleetCount / _vehicles.length) * 100;
  }

  double get fleetFuelEfficiency {
    // Basic mock implementation since fuel logs are nested in actual API
    double totalKm = _vehicles.fold(0.0, (sum, v) => sum + v.currentOdometer);
    double totalFuel = _fuelLogs.fold(0.0, (sum, f) => sum + f.liters);
    if (totalFuel == 0) return 0.0;
    return totalKm > 0 ? totalKm / 100 : 0.0; // dummy efficiency metric
  }

  // --- Mock Logs functionality for other views ---
  final List<MaintenanceLog> _maintenanceLogs = [];
  final List<FuelLog> _fuelLogs = [];

  List<MaintenanceLog> get maintenanceLogs => _maintenanceLogs;
  List<FuelLog> get fuelLogs => _fuelLogs;

  void addMaintenanceLog(MaintenanceLog log) {
    _maintenanceLogs.add(log);
    updateVehicleStatusLocal(log.vehicleId, 'IN_SHOP');
  }

  void addFuelLog(FuelLog log) {
    _fuelLogs.add(log);
    notifyListeners();
  }

  double getTotalOperatingCost(String vehicleId) {
    final mCost = _maintenanceLogs
        .where((l) => l.vehicleId == vehicleId)
        .fold(0.0, (sum, l) => sum + l.cost);
    final fCost = _fuelLogs
        .where((l) => l.vehicleId == vehicleId)
        .fold(0.0, (sum, l) => sum + l.cost);
    return mCost + fCost;
  }
}

// Restore Mock Classes for legacy views
class MaintenanceLog {
  final String vehicleId;
  final String description;
  final double cost;
  final DateTime date;
  MaintenanceLog(this.vehicleId, this.description, this.cost, this.date);
}

class FuelLog {
  final String vehicleId;
  final double liters;
  final double cost;
  final DateTime date;
  FuelLog(this.vehicleId, this.liters, this.cost, this.date);
}
