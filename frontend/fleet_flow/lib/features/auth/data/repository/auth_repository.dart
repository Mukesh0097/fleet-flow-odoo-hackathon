import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fleet_flow/core/services/api_services.dart';
import 'package:fleet_flow/core/constants/endpoints.dart';
import 'package:fleet_flow/features/auth/data/models/login_model.dart';
import 'package:fleet_flow/features/auth/data/models/auth_otp_model.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  Future<ApiResult<LoginResponse>> login(String email, String password) async {
    try {
      final body = {"email": email, "password": password};
      final res = await _apiService.post(Endpoints.login, body);
      final resBody = jsonDecode(res.body);

      final loginRes = LoginResponse.fromJson(resBody);
      return ApiResult.success(loginRes);
    } on ApiException catch (e) {
      debugPrint(e.toString());
      return ApiResult.failure(e.message);
    } catch (e) {
      debugPrint("login-error: $e");
      return ApiResult.failure("login-error: $e");
    }
  }

  Future<ApiResult<SendAuthOtpResponse>> sendAuthOtp(int userId) async {
    try {
      final res = await _apiService.post(Endpoints.sendOtp, {
        "user_id": userId,
      });
      final resBody = jsonDecode(res.body);

      final otpRes = SendAuthOtpResponse.fromJson(resBody);
      return ApiResult.success(otpRes);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message);
    } catch (e) {
      return ApiResult.failure("send-otp-error: $e");
    }
  }

  Future<ApiResult<VerifyAuthOtpResponse>> verifyAuthOtp(
    int otpId,
    int otp,
  ) async {
    try {
      final body = {"otp_id": otpId, "otp": otp};
      final res = await _apiService.post(Endpoints.verifyOtp, body);
      final resBody = jsonDecode(res.body);

      final verifyRes = VerifyAuthOtpResponse.fromJson(resBody);
      return ApiResult.success(verifyRes);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message);
    } catch (e) {
      return ApiResult.failure("verify-otp-error: $e");
    }
  }

  Future<ApiResult<SendVerificationEmailResponse>> verifyEmail(
    String email,
  ) async {
    try {
      final body = {"email": email};
      debugPrint(body.toString());
      final res = await _apiService.post(
        Endpoints.verifyEmail,
        body,
        authToken: true,
      );
      final resBody = jsonDecode(res.body);

      final verifyRes = SendVerificationEmailResponse.fromJson(resBody);
      return ApiResult.success(verifyRes);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message);
    } catch (e) {
      return ApiResult.failure("verify-otp-error: $e");
    }
  }

  Future<void> forgotPassword(String email) async {
    await _apiService.post(Endpoints.forgotPassword, {"email": email});
  }

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    await _apiService.post(Endpoints.resetPassword, {
      "reset_token": resetToken,
      "new_password": newPassword,
    });
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _apiService.post(Endpoints.changePassword, {
      "old_password": oldPassword,
      "new_password": newPassword,
    }, authToken: true);
  }

  Future<void> logout() async {
    // Clear tokens or call api
  }
}
