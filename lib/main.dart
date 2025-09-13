import 'package:eco_coins_mobile_app/controllers/auth_controller.dart';
import 'package:eco_coins_mobile_app/controllers/coin_controller.dart';
import 'package:eco_coins_mobile_app/controllers/maintenance_controller.dart';
import 'package:eco_coins_mobile_app/controllers/tree_controller.dart';
import 'package:eco_coins_mobile_app/services/database_service.dart';
import 'package:eco_coins_mobile_app/services/notification_service.dart';
import 'package:eco_coins_mobile_app/utils/constants.dart';
import 'package:eco_coins_mobile_app/utils/themes.dart';
import 'package:eco_coins_mobile_app/views/auth/login_screen.dart';
import 'package:eco_coins_mobile_app/views/auth/signup_screen.dart';
import 'package:eco_coins_mobile_app/views/home/dashboard_screen.dart';
import 'package:eco_coins_mobile_app/views/home/maintenance_screen.dart';
import 'package:eco_coins_mobile_app/views/home/plant_tree_screen.dart';
import 'package:eco_coins_mobile_app/views/profile/help_support_screen.dart';
import 'package:eco_coins_mobile_app/views/profile/privacy_settings_screen.dart';
import 'package:eco_coins_mobile_app/views/profile/profile_screen.dart';
import 'package:eco_coins_mobile_app/views/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final DatabaseService databaseService = DatabaseService();
  await databaseService.initDatabase();

  final NotificationService notificationService = NotificationService();
  await notificationService.initializeNotifications();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(databaseService),
        ),
        ChangeNotifierProvider(
          create: (_) => TreeController(databaseService),
        ),
        ChangeNotifierProvider(
          create: (_) => CoinController(databaseService),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              MaintenanceController(databaseService, notificationService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eco Coins',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        AppConstants.splashRoute: (context) => const SplashScreen(),
        AppConstants.loginRoute: (context) => const LoginScreen(),
        AppConstants.signupRoute: (context) => const SignupScreen(),
        AppConstants.dashboardRoute: (context) => const DashboardScreen(),
        AppConstants.plantTreeRoute: (context) => const PlantTreeScreen(),
        AppConstants.profileRoute: (context) => const ProfileScreen(),
        AppConstants.privacySettingsRoute: (context) =>
            const PrivacySettingsScreen(),
        AppConstants.helpSupportRoute: (context) => const HelpSupportScreen(),
      },
      // Handle routes that require arguments
      onGenerateRoute: (settings) {
        if (settings.name == AppConstants.maintainRoute) {
          // Handle '/maintain' route with arguments
          final args = settings.arguments;
          return MaterialPageRoute(
            builder: (context) => MaintenanceScreen(tree: args),
          );
        }
        return null;
      },
    );
  }
}
