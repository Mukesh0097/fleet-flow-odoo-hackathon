import 'dart:convert';
import 'package:fleet_flow/core/services/api_services.dart';
import 'package:fleet_flow/features/users/data/models/user_model.dart';
import 'package:fleet_flow/features/auth/data/models/login_model.dart';

class UserRepository {
  final ApiService _apiService;

  UserRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  Future<ApiResult<List<UserModel>>> getUsers() async {
    try {
      final response = await _apiService.get(
        '/api/auth/users',
        authToken: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        final usersResponse = UsersListResponse.fromJson(body);
        if (usersResponse.success) {
          return ApiResult.success(usersResponse.data);
        } else {
          return ApiResult.failure("Failed to parse users data");
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

  Future<ApiResult<LoginModel>> registerUser(
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await _apiService.post(
        '/api/auth/register',
        userData,
        authToken: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return ApiResult.success(LoginModel.fromJson(body['data']));
        }
        return ApiResult.failure(body['message'] ?? "Registration failed");
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
