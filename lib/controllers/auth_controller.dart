import 'package:eco_coins_mobile_app/models/user_model.dart';
import 'package:eco_coins_mobile_app/services/database_service.dart';
import 'package:flutter/material.dart';

/// Authentication state
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Controller class for handling authentication
class AuthController with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  AuthState _state = AuthState.initial;
  User? _currentUser;
  String? _errorMessage;

  /// Getter for auth state
  AuthState get state => _state;

  /// Getter for current user
  User? get currentUser => _currentUser;

  /// Getter for error message
  String? get errorMessage => _errorMessage;

  /// Initialize authentication state
  Future<void> initialize() async {
    // Check if there's a user already logged in (in a real app, this might use SharedPreferences)
    // For now, we'll just set the state to unauthenticated
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  /// Register a new user
  Future<bool> register(
      {required String email,
      required String name,
      required String password}) async {
    try {
      _state = AuthState.loading;
      notifyListeners();

      // Check if user already exists
      final User? existingUser = await _databaseService.getUserByEmail(email);
      if (existingUser != null) {
        _state = AuthState.error;
        _errorMessage = 'A user with this email already exists';
        notifyListeners();
        return false;
      }

      // Create new user (in a real app, you'd hash the password)
      final User user = User(
        email: email,
        name: name,
        coinsBalance: 0,
        createdAt: DateTime.now(),
      );

      final int userId = await _databaseService.createUser(user);

      // Get the user with the assigned id
      _currentUser = await _databaseService.getUserById(userId);
      _state = AuthState.authenticated;
      notifyListeners();

      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'Registration failed: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Login a user
  Future<bool> login({required String email, required String password}) async {
    try {
      _state = AuthState.loading;
      notifyListeners();

      // Get user by email
      final User? user = await _databaseService.getUserByEmail(email);

      // Check if user exists (in a real app, you'd verify the password too)
      if (user == null) {
        _state = AuthState.error;
        _errorMessage = 'Invalid email or password';
        notifyListeners();
        return false;
      }

      // Set current user and update state
      _currentUser = user;
      _state = AuthState.authenticated;
      notifyListeners();

      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'Login failed: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Logout the current user
  void logout() {
    _currentUser = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  /// Get updated user data
  Future<void> refreshUserData() async {
    if (_currentUser != null && _currentUser!.id != null) {
      try {
        final User? updatedUser =
            await _databaseService.getUserById(_currentUser!.id!);
        if (updatedUser != null) {
          _currentUser = updatedUser;
          notifyListeners();
        }
      } catch (e) {
        _errorMessage = 'Failed to refresh user data: ${e.toString()}';
        notifyListeners();
      }
    }
  }

  /// Update user information
  Future<bool> updateUser({required String name}) async {
    if (_currentUser != null && _currentUser!.id != null) {
      try {
        final User updatedUser = _currentUser!.copyWith(name: name);
        await _databaseService.updateUser(updatedUser);
        _currentUser = updatedUser;
        notifyListeners();
        return true;
      } catch (e) {
        _errorMessage = 'Failed to update user: ${e.toString()}';
        notifyListeners();
        return false;
      }
    }
    return false;
  }
}
