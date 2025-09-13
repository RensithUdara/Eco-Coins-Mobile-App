import 'package:eco_coins_mobile_app/controllers/auth_controller.dart';
import 'package:eco_coins_mobile_app/utils/constants.dart';
import 'package:eco_coins_mobile_app/views/home/dashboard_screen.dart';
import 'package:eco_coins_mobile_app/views/auth/login_screen.dart';
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
    _initializeAuth();
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

    // Listen to auth state changes and navigate accordingly
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        if (authController.state == AuthState.authenticated) {
          return Navigator(
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (_) => const DashboardPlaceholder(),
            ),
          );
        } else {
          return Navigator(
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (_) => const LoginPlaceholder(),
            ),
          );
        }
      },
    );
  }
}

/// Placeholder widget that will navigate to the dashboard
class DashboardPlaceholder extends StatefulWidget {
  const DashboardPlaceholder({super.key});

  @override
  State<DashboardPlaceholder> createState() => _DashboardPlaceholderState();
}

class _DashboardPlaceholderState extends State<DashboardPlaceholder> {
  @override
  void initState() {
    super.initState();
    // Navigate after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, AppConstants.dashboardRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Placeholder widget that will navigate to the login screen
class LoginPlaceholder extends StatefulWidget {
  const LoginPlaceholder({super.key});

  @override
  State<LoginPlaceholder> createState() => _LoginPlaceholderState();
}

class _LoginPlaceholderState extends State<LoginPlaceholder> {
  @override
  void initState() {
    super.initState();
    // Navigate after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
