import 'package:eco_coins_mobile_app/models/user_model.dart';
import 'package:eco_coins_mobile_app/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final DatabaseService _databaseService;

  AuthController(this._databaseService);

  // Constants for SharedPreferences keys
  static const String _keyEmail = 'user_email';
  static const String _keyPassword = 'user_password';
  static const String _keyRememberMe = 'remember_me';

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
    // Set state to unauthenticated without notifying listeners
    // This avoids triggering notifications during build
    _state = AuthState.unauthenticated;
    // We don't call notifyListeners() here to avoid issues during build
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
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
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

      // Save credentials if remember me is checked
      if (rememberMe) {
        await _saveUserCredentials(email, password, rememberMe);
      } else {
        // Clear saved credentials if remember me is unchecked
        await _clearUserCredentials();
      }

      notifyListeners();
      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'Login failed: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Save user credentials to SharedPreferences
  Future<void> _saveUserCredentials(
      String email, String password, bool rememberMe) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPassword, password);
    await prefs.setBool(_keyRememberMe, rememberMe);
  }

  /// Clear saved user credentials
  Future<void> _clearUserCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPassword);
    await prefs.remove(_keyRememberMe);
  }

  /// Logout the current user
  Future<void> logout() async {
    _currentUser = null;
    _state = AuthState.unauthenticated;

    // Clear saved credentials
    await _clearUserCredentials();

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
  
  /// Update user profile (name and email)
  Future<bool> updateUserProfile({
    required String name,
    required String email,
  }) async {
    if (_currentUser != null && _currentUser!.id != null) {
      try {
        // Check if email already exists for a different user
        if (email != _currentUser!.email) {
          final User? existingUser = await _databaseService.getUserByEmail(email);
          if (existingUser != null && existingUser.id != _currentUser!.id) {
            _errorMessage = 'A user with this email already exists';
            notifyListeners();
            return false;
          }
        }
        
        // Update user with new information
        final User updatedUser = _currentUser!.copyWith(
          name: name,
          email: email,
        );
        await _databaseService.updateUser(updatedUser);
        _currentUser = updatedUser;
        notifyListeners();
        return true;
      } catch (e) {
        _errorMessage = 'Failed to update profile: ${e.toString()}';
        notifyListeners();
        return false;
      }
    }
    _errorMessage = 'User not authenticated';
    notifyListeners();
    return false;
  }

  /// Try to auto login based on stored credentials
  Future<bool> tryAutoLogin() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Check if remember me was enabled
      final bool rememberMe = prefs.getBool(_keyRememberMe) ?? false;
      if (!rememberMe) {
        _state = AuthState.unauthenticated;
        notifyListeners();
        return false;
      }

      // Get stored credentials
      final String? email = prefs.getString(_keyEmail);
      final String? password = prefs.getString(_keyPassword);

      if (email == null || password == null) {
        _state = AuthState.unauthenticated;
        notifyListeners();
        return false;
      }

      // Try to login with stored credentials
      return await login(email: email, password: password, rememberMe: true);
    } catch (e) {
      _state = AuthState.unauthenticated;
      notifyListeners();
      return false;
    }
  }
}
