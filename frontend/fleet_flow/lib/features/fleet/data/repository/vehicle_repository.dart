import 'dart:convert';
import 'package:fleet_flow/core/services/api_services.dart';
import 'package:fleet_flow/features/fleet/data/models/vehicle_model.dart';

class VehicleRepository {
  final ApiService _apiService;

  VehicleRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  Future<ApiResult<List<VehicleModel>>> getVehicles() async {
    try {
      final response = await _apiService.get('/api/vehicles', authToken: true);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        final res = VehiclesListResponse.fromJson(body);
        if (res.success) {
          return ApiResult.success(res.data);
        } else {
          return ApiResult.failure("Failed to parse vehicles data");
        }
      }
      return ApiResult.failure(
        "Unexpected status code: ${response.statusCode}",
      );
    } catch (e) {
      if (e is ApiException) {
        return ApiResult.failure(e.message);
      }
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<VehicleModel>> createVehicle(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.post(
        '/api/vehicles',
        data,
        authToken: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        final res = VehicleResponse.fromJson(body);
        if (res.success && res.data != null) {
          return ApiResult.success(res.data);
        }
        return ApiResult.failure(res.message);
      }
      return ApiResult.failure(
        "Unexpected status code: ${response.statusCode}",
      );
    } catch (e) {
      if (e is ApiException) {
        return ApiResult.failure(e.message);
      }
      return ApiResult.failure(e.toString());
    }
  }
}
