class VehicleModel {
  final String id;
  final String name;
  final String model;
  final String licensePlate;
  final String vehicleType;
  final double maxCapacityKg;
  final double currentOdometer;
  final double? acquisitionCost;
  final String status;
  final String? region;
  final bool isRetired;
  final DateTime createdAt;
  final DateTime updatedAt;

  VehicleModel({
    required this.id,
    required this.name,
    required this.model,
    required this.licensePlate,
    required this.vehicleType,
    required this.maxCapacityKg,
    required this.currentOdometer,
    this.acquisitionCost,
    required this.status,
    this.region,
    required this.isRetired,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      model: json['model'] as String? ?? '',
      licensePlate: json['licensePlate'] as String? ?? '',
      vehicleType: json['vehicleType'] as String? ?? 'VAN',
      maxCapacityKg: (json['maxCapacityKg'] as num?)?.toDouble() ?? 0.0,
      currentOdometer: (json['currentOdometer'] as num?)?.toDouble() ?? 0.0,
      acquisitionCost: (json['acquisitionCost'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'AVAILABLE',
      region: json['region'] as String?,
      isRetired: json['isRetired'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class VehiclesListResponse {
  final bool success;
  final List<VehicleModel> data;

  VehiclesListResponse({required this.success, required this.data});

  factory VehiclesListResponse.fromJson(Map<String, dynamic> json) {
    return VehiclesListResponse(
      success: json['success'] as bool? ?? false,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => VehicleModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class VehicleResponse {
  final bool success;
  final String message;
  final VehicleModel? data;

  VehicleResponse({required this.success, required this.message, this.data});

  factory VehicleResponse.fromJson(Map<String, dynamic> json) {
    return VehicleResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null ? VehicleModel.fromJson(json['data']) : null,
    );
  }
}
