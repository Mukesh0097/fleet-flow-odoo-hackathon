import 'package:flutter/foundation.dart';
import 'package:fleet_flow/features/users/data/models/user_model.dart';
import 'package:fleet_flow/features/users/data/repository/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository;

  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  UserProvider({UserRepository? userRepository})
    : _userRepository = userRepository ?? UserRepository();

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _userRepository.getUsers();

    if (result.isSuccess && result.data != null) {
      _users = result.data!;
    } else {
      _errorMessage = result.error ?? "Failed to load users";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> registerUser(
    String email,
    String password,
    String name,
    String role,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final userData = {
      "email": email,
      "password": password,
      "name": name,
      "role": role,
    };

    final result = await _userRepository.registerUser(userData);

    _isLoading = false;

    if (result.isSuccess) {
      // Optionally reload users after successful registration
      await loadUsers();
      return true;
    } else {
      _errorMessage = result.error ?? "Failed to register user";
      notifyListeners();
      return false;
    }
  }
}
