import 'package:flutter/foundation.dart';
import 'package:fleet_flow/features/auth/data/repository/auth_repository.dart';
import 'package:fleet_flow/core/services/storage_services.dart';

enum UserRole { fleetManager, dispatcher, safetyOfficer, financialAnalyst }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  UserRole? _role;
  String? _errorMessage;

  AuthProvider({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  UserRole? get role => _role;
  String? get errorMessage => _errorMessage;

  Future<void> checkAuthStatus() async {
    final token = StorageServices.getToken();
    final roleStr = StorageServices.getRole();

    if (token != null && token.isNotEmpty) {
      _isAuthenticated = true;
      if (roleStr != null) {
        _role = _parseRole(roleStr);
      }
    } else {
      _isAuthenticated = false;
      _role = null;
    }
    notifyListeners();
  }

  UserRole _parseRole(String roleStr) {
    if (roleStr == 'FLEET_MANAGER') return UserRole.fleetManager;
    if (roleStr == 'DISPATCHER') return UserRole.dispatcher;
    if (roleStr == 'SAFETY_OFFICER') return UserRole.safetyOfficer;
    return UserRole.financialAnalyst; // Fallback
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _authRepository.login(email, password);

      if (res.isSuccess && res.data != null) {
        final loginResponse = res.data!;
        final token = loginResponse.token;
        final roleStr = loginResponse.data.role;

        await StorageServices.saveToken(token);
        await StorageServices.saveRole(roleStr);

        _role = _parseRole(roleStr);
        _isAuthenticated = true;
      } else {
        _errorMessage = res.error ?? "Login failed";
        _isAuthenticated = false;
        _role = null;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isAuthenticated = false;
      _role = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.logout();
    } catch (e) {
      // Log error but proceed with local logout
    }

    await StorageServices.removeToken();
    await StorageServices.removeRole();

    _isAuthenticated = false;
    _role = null;
    _isLoading = false;
    notifyListeners();
  }
}
