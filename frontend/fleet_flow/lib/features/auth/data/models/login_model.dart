class LoginModel {
  final String id;
  final String email;
  final String name;
  final String role;

  LoginModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
    );
  }
}

class LoginResponse {
  final bool success;
  final String message;
  final LoginModel data;
  final String token;

  LoginResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: LoginModel.fromJson(json['data'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }
}
