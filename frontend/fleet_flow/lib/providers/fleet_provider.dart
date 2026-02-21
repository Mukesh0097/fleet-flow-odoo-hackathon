import 'package:flutter/foundation.dart';

enum VehicleStatus { available, onTrip, inShop, retired }

enum VehicleType { truck, van, bike }

class Vehicle {
  final String id;
  final String name;
  final VehicleType type;
  final String licensePlate;
  final double maxLoadCapacity;
  double odometer;
  VehicleStatus status;

  Vehicle({
    required this.id,
    required this.name,
    required this.type,
    required this.licensePlate,
    required this.maxLoadCapacity,
    required this.odometer,
    this.status = VehicleStatus.available,
  });
}

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

class FleetProvider extends ChangeNotifier {
  final List<Vehicle> _vehicles = [
    Vehicle(
      id: 'v1',
      name: 'Truck-01',
      type: VehicleType.truck,
      licensePlate: 'DEF-456',
      maxLoadCapacity: 5000,
      odometer: 15000,
    ),
    Vehicle(
      id: 'v2',
      name: 'Van-05',
      type: VehicleType.van,
      licensePlate: 'ABC-123',
      maxLoadCapacity: 500,
      odometer: 45000,
    ),
    Vehicle(
      id: 'v3',
      name: 'Bike-02',
      type: VehicleType.bike,
      licensePlate: 'XYZ-987',
      maxLoadCapacity: 50,
      odometer: 2000,
    ),
  ];

  final List<MaintenanceLog> _maintenanceLogs = [];
  final List<FuelLog> _fuelLogs = [];

  List<Vehicle> get vehicles => _vehicles;
  List<Vehicle> get availableVehicles =>
      _vehicles.where((v) => v.status == VehicleStatus.available).toList();
  List<MaintenanceLog> get maintenanceLogs => _maintenanceLogs;
  List<FuelLog> get fuelLogs => _fuelLogs;

  void addVehicle(Vehicle vehicle) {
    _vehicles.add(vehicle);
    notifyListeners();
  }

  void updateVehicleStatus(String vehicleId, VehicleStatus newStatus) {
    final index = _vehicles.indexWhere((v) => v.id == vehicleId);
    if (index != -1) {
      _vehicles[index].status = newStatus;
      notifyListeners();
    }
  }

  void updateOdometer(String vehicleId, double newOdometer) {
    final index = _vehicles.indexWhere((v) => v.id == vehicleId);
    if (index != -1) {
      _vehicles[index].odometer = newOdometer;
      notifyListeners();
    }
  }

  void addMaintenanceLog(MaintenanceLog log) {
    _maintenanceLogs.add(log);
    updateVehicleStatus(log.vehicleId, VehicleStatus.inShop);
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

  // Dashboard KPIs
  int get activeFleetCount =>
      _vehicles.where((v) => v.status == VehicleStatus.onTrip).length;
  int get maintenanceAlertsCount =>
      _vehicles.where((v) => v.status == VehicleStatus.inShop).length;

  double get utilizationRate {
    if (_vehicles.isEmpty) return 0.0;
    return (activeFleetCount / _vehicles.length) * 100;
  }

  double get fleetFuelEfficiency {
    double totalKm = _vehicles.fold(0.0, (sum, v) => sum + v.odometer);
    double totalFuel = _fuelLogs.fold(0.0, (sum, f) => sum + f.liters);
    if (totalFuel == 0) return 0.0;
    return totalKm / totalFuel;
  }
}
