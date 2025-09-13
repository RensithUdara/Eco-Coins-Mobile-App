import 'dart:async';

import 'package:eco_coins_mobile_app/controllers/auth_controller.dart';
import 'package:eco_coins_mobile_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Splash screen displayed when the app starts
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // Start animation
    _animationController.forward();

    // Initialize auth controller
    final authController = Provider.of<AuthController>(context, listen: false);
    authController.initialize();

    // Navigate to the appropriate screen after a delay
    Timer(const Duration(seconds: 3), () {
      if (authController.state == AuthState.authenticated) {
        Navigator.pushReplacementNamed(context, AppConstants.dashboardRoute);
      } else {
        Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo
                Icon(
                  Icons.eco,
                  size: 100,
                  color: ColorConstants.primary,
                ),
                SizedBox(height: 24),
                // App name
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.primary,
                  ),
                ),
                SizedBox(height: 8),
                // Tagline
                Text(
                  AppConstants.appTagline,
                  style: TextStyle(
                    fontSize: 16,
                    color: ColorConstants.textSecondary,
                  ),
                ),
                SizedBox(height: 64),
                // Loading indicator
                CircularProgressIndicator(
                  color: ColorConstants.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
