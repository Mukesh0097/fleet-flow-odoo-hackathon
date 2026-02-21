import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:fleet_flow/core/constants/constants.dart';
import 'package:fleet_flow/core/services/storage_services.dart';
import 'package:fleet_flow/common/widgets/app_toast.dart';

class ApiService {
  static const String baseUrl = Constants.baseurl;

  static Future<Map<String, String>> _headersWithToken(bool authToken) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (authToken) {
      final token = StorageServices.getToken();

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<http.Response> get(
    String endpoint, {
    List<String>? pathParams,
    Map<String, String>? queryParams,
    bool authToken = false,
  }) async {
    String finalEndpoint = endpoint;
    if (pathParams != null && pathParams.isNotEmpty) {
      finalEndpoint += "/${pathParams.join("/")}";
    }

    final uri = Uri.https(baseUrl, finalEndpoint, queryParams);
    final headers = await _headersWithToken(authToken);

    final response = await http.get(uri, headers: headers);

    debugPrint("GET Request: ${uri.toString()}");
    debugPrint("statusCode: ${response.statusCode}");
    debugPrint("Response: ${response.body}");

    return _handleResponse(response);
  }

  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool authToken = false,
  }) async {
    final headers = await _headersWithToken(authToken);

    final response = await http.post(
      Uri.https(baseUrl, endpoint),
      headers: headers,
      body: jsonEncode(body),
    );

    debugPrint(response.request!.url.toString());
    debugPrint(response.body);

    return _handleResponse(response);
  }

  Future<http.Response> patch(
    String endpoint,
    Map<String, dynamic>? body, {
    List<String>? pathParams,
    Map<String, dynamic>? queryParams,
    bool authToken = false,
  }) async {
    String finalEndpoint = endpoint;
    if (pathParams != null && pathParams.isNotEmpty) {
      finalEndpoint += "/${pathParams.join("/")}";
    }

    final uri = Uri.https(baseUrl, finalEndpoint, queryParams);

    final hasBody = body != null && (body.isNotEmpty);

    final headers = await _headersWithToken(authToken);

    final response = await http.patch(
      uri,
      headers: headers,
      body: hasBody ? jsonEncode(body) : null,
    );

    debugPrint("PATCH Request: ${uri.toString()}");
    debugPrint("statusCode: ${response.statusCode}");
    debugPrint("Response: ${response.body}");

    return _handleResponse(response);
  }

  Future<http.Response?> postWithTokenAndFiles({
    required String endpoint,
    required Map<String, dynamic> data,
    required File file,
    Map<String, String>? headers,
    Map<String, String>? queryParams,
    String? authToken,
  }) async {
    try {
      final uri = Uri.https(baseUrl, endpoint);
      final authHeaders = {'Authorization': 'Bearer $authToken'};

      debugPrint('Multipart Request to: ${uri.toString()}');
      debugPrint('Headers: ${authHeaders.toString()}');
      debugPrint('Data: ${jsonEncode(data)}');

      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll(authHeaders);

      String fileName = file.path.split("/").last;

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: fileName,
          contentType: MediaType('image', fileName.split('.').last),
        ),
      );

      request.fields.addAll(_flattenData(data));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      var httpResponse = http.Response(responseBody, response.statusCode);

      debugPrint('Response status: ${httpResponse.statusCode}');
      debugPrint('Response body: ${httpResponse.body}');

      if (response.statusCode == 401) {
        AppToast.error("Your session has expired. Please log in again.");
        return null;
      } else {
        return _handleResponse(httpResponse);
      }
    } on http.ClientException catch (e) {
      throw e.toString();
    } catch (e) {
      debugPrint('Error in postWithTokenAndFiles: $e');
      rethrow;
    }
  }

  Map<String, String> _flattenData(Map<String, dynamic> data) {
    final Map<String, String> flatData = {};

    for (var entry in data.entries) {
      if (entry.value is Map) {
        (entry.value as Map).forEach((key, value) {
          flatData['${entry.key}.$key'] = value.toString();
        });
      } else {
        flatData[entry.key] = entry.value.toString();
      }
    }

    return flatData;
  }

  static http.Response _handleResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response;
    }

    dynamic responseBody;
    try {
      responseBody = jsonDecode(response.body);
    } catch (_) {
      responseBody = {};
    }

    String errorMessage;
    switch (response.statusCode) {
      case 400:
        errorMessage = responseBody['message'] ?? 'Bad Request';
        break;
      case 401:
        errorMessage = responseBody['message'] ?? 'Unauthorized';
        break;
      case 403:
        errorMessage = responseBody['message'] ?? 'Forbidden';
        break;
      case 404:
        errorMessage = responseBody['message'] ?? 'Not found';
        break;
      case 422:
        errorMessage = responseBody['message'] ?? 'Validation failed';
        break;
      case 500:
        errorMessage = responseBody['message'] ?? 'Server Error';
        break;
      default:
        errorMessage =
            responseBody['message'] ?? 'Error ${response.statusCode}';
        break;
    }

    AppToast.error(errorMessage);
    throw ApiException(errorMessage, response.body);
  }
}

class ApiResult<T> {
  final T? data;
  final String? error;

  ApiResult.success(this.data) : error = null;

  ApiResult.failure(this.error) : data = null;

  bool get isSuccess => data != null;
}

class ApiException implements Exception {
  final String message;
  final String responseBody;

  ApiException(this.message, this.responseBody);

  @override
  String toString() => '$message: $responseBody';
}
