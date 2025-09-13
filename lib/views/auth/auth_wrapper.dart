import 'package:eco_coins_mobile_app/controllers/auth_controller.dart';
import 'package:eco_coins_mobile_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A wrapper widget that handles authentication state and navigation
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to ensure we're not initializing during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAuth();
    });
  }

  Future<void> _initializeAuth() async {
    final authController = Provider.of<AuthController>(context, listen: false);

    try {
      // First set the initial state
      await authController.initialize();

      // Then try auto-login
      await authController.tryAutoLogin();
    } finally {
      // Update state regardless of success/failure
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  bool _hasNavigated = false;
  
  @override
  Widget build(BuildContext context) {
    // Show loading indicator while initializing
    if (_isInitializing) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Navigate only once based on auth state
    if (!_hasNavigated) {
      _hasNavigated = true;
      // Schedule navigation after this frame completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        
        final authController =
            Provider.of<AuthController>(context, listen: false);
        if (authController.state == AuthState.authenticated) {
          Navigator.pushReplacementNamed(context, AppConstants.dashboardRoute);
        } else {
          Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
        }
      });
    }

    // Return a loading indicator while navigating
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
