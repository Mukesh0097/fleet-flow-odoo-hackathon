import 'package:flutter/foundation.dart';
import 'package:fleet_flow/features/fleet/data/models/vehicle_model.dart';

enum TripStatus { draft, dispatched, completed, cancelled }

class Trip {
  final String id;
  final String driverId;
  final String vehicleId;
  final double cargoWeight;
  TripStatus status;

  Trip({
    required this.id,
    required this.driverId,
    required this.vehicleId,
    required this.cargoWeight,
    this.status = TripStatus.draft,
  });
}

class TripProvider extends ChangeNotifier {
  final List<Trip> _trips = [];

  List<Trip> get trips => _trips;
  int get pendingCargoCount =>
      _trips.where((t) => t.status == TripStatus.draft).length;

  String? validateAndCreateTrip({
    required String driverId,
    required VehicleModel vehicle,
    required double cargoWeight,
  }) {
    if (cargoWeight > vehicle.maxCapacityKg) {
      return "Cargo weight exceeds vehicle's max capacity (${vehicle.maxCapacityKg}).";
    }

    final newTrip = Trip(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      driverId: driverId,
      vehicleId: vehicle.id,
      cargoWeight: cargoWeight,
      status: TripStatus.dispatched,
    );

    _trips.add(newTrip);
    notifyListeners();
    return null; // Success
  }

  void completeTrip(String tripId) {
    final index = _trips.indexWhere((t) => t.id == tripId);
    if (index != -1) {
      _trips[index].status = TripStatus.completed;
      notifyListeners();
    }
  }
}
