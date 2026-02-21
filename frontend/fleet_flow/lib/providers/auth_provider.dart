import 'package:flutter/foundation.dart';

enum UserRole { manager, dispatcher, safetyOfficer, financialAnalyst }

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  UserRole? _role;

  bool get isAuthenticated => _isAuthenticated;
  UserRole? get role => _role;

  void login(String email, String password) {
    if (email.contains('manager')) {
      _role = UserRole.manager;
    } else if (email.contains('dispatcher')) {
      _role = UserRole.dispatcher;
    } else if (email.contains('safety')) {
      _role = UserRole.safetyOfficer;
    } else {
      _role = UserRole.financialAnalyst;
    }

    _isAuthenticated = true;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _role = null;
    notifyListeners();
  }
}
