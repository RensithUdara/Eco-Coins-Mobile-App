import 'package:flutter/material.dart';

/// This file contains constants used throughout the app

/// App Constants
class AppConstants {
  static const String appName = 'Eco Coins';
  static const String appTagline = 'Harvest Green, Collect Gold';
  static const String welcomeMessage = 'Welcome to Eco Journey!';
  
  // Routes
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String dashboardRoute = '/dashboard';
  static const String plantTreeRoute = '/plant-tree';
  static const String maintainRoute = '/maintain';
}

/// Color Constants
class ColorConstants {
  // Primary colors (greens)
  static const Color primaryDark = Color(0xFF2E7D32);
  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryLight = Color(0xFF66BB6A);
  
  // Secondary colors (golds)
  static const Color secondary = Color(0xFFFFD700);
  static const Color secondaryLight = Color(0xFFFFC107);
  
  // Background colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);
}

/// Maintenance Update Periods
class MaintenancePeriods {
  static const int oneMonth = 30; // days
  static const int threeMonths = 90; // days
  static const int sixMonths = 180; // days
  static const int oneYear = 365; // days
}

/// Coin Rewards
class CoinRewards {
  static const int treePlanting = 100;
  static const int oneMonthUpdate = 20;
  static const int threeMonthUpdate = 30;
  static const int sixMonthUpdate = 40;
  static const int oneYearUpdate = 50;
}

/// Asset Paths
class AssetPaths {
  static const String treeLogo = 'assets/images/tree_logo.png';
  static const String coinIcon = 'assets/images/coin_icon.png';
  static const String plantIcon = 'assets/images/plant_icon.png';
  static const String cameraIcon = 'assets/images/camera_icon.png';
}

/// Database Constants
class DBConstants {
  static const String dbName = 'eco_coins.db';
  static const int dbVersion = 1;
  
  // Table names
  static const String userTable = 'users';
  static const String treeTable = 'trees';
  static const String maintenanceTable = 'maintenance';
  static const String transactionTable = 'transactions';
}