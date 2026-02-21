import 'dart:convert';
import 'package:fleet_flow/core/services/api_services.dart';
import 'package:fleet_flow/features/driver/data/models/driver_model.dart';

class DriverRepository {
  final ApiService _apiService;

  DriverRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  Future<ApiResult<List<DriverModel>>> getDrivers() async {
    try {
      final response = await _apiService.get('/api/drivers', authToken: true);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        final res = DriversListResponse.fromJson(body);
        if (res.success) {
          return ApiResult.success(res.data);
        } else {
          return ApiResult.failure("Failed to parse drivers data");
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

  Future<ApiResult<DriverModel>> createDriver(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post(
        '/api/drivers',
        data,
        authToken: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        final res = DriverResponse.fromJson(body);
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
