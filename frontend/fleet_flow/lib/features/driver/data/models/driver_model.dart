class DriverModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String status;
  final String licenseNumber;
  final DateTime licenseExpiryDate;
  final List<String> licenseCategories;
  final double safetyScore;
  final int totalTrips;
  final int completedTrips;
  final DateTime createdAt;
  final DateTime updatedAt;

  DriverModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    required this.licenseNumber,
    required this.licenseExpiryDate,
    required this.licenseCategories,
    required this.safetyScore,
    required this.totalTrips,
    required this.completedTrips,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      status: json['status'] as String? ?? 'AVAILABLE',
      licenseNumber: json['licenseNumber'] as String? ?? '',
      licenseExpiryDate: json['licenseExpiryDate'] != null
          ? DateTime.tryParse(json['licenseExpiryDate']) ?? DateTime.now()
          : DateTime.now(),
      licenseCategories:
          (json['licenseCategories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      safetyScore: (json['safetyScore'] as num?)?.toDouble() ?? 100.0,
      totalTrips: json['totalTrips'] as int? ?? 0,
      completedTrips: json['completedTrips'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class DriversListResponse {
  final bool success;
  final List<DriverModel> data;

  DriversListResponse({required this.success, required this.data});

  factory DriversListResponse.fromJson(Map<String, dynamic> json) {
    return DriversListResponse(
      success: json['success'] as bool? ?? false,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => DriverModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class DriverResponse {
  final bool success;
  final String message;
  final DriverModel? data;

  DriverResponse({required this.success, required this.message, this.data});

  factory DriverResponse.fromJson(Map<String, dynamic> json) {
    return DriverResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null ? DriverModel.fromJson(json['data']) : null,
    );
  }
}
