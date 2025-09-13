import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eco_coins_mobile_app/controllers/auth_controller.dart';
import 'package:eco_coins_mobile_app/controllers/coin_controller.dart';
import 'package:eco_coins_mobile_app/controllers/maintenance_controller.dart';
import 'package:eco_coins_mobile_app/controllers/tree_controller.dart';
import 'package:eco_coins_mobile_app/services/database_service.dart';
import 'package:eco_coins_mobile_app/services/notification_service.dart';
import 'package:eco_coins_mobile_app/utils/themes.dart';
import 'package:eco_coins_mobile_app/views/auth/login_screen.dart';
import 'package:eco_coins_mobile_app/views/auth/signup_screen.dart';
import 'package:eco_coins_mobile_app/views/home/dashboard_screen.dart';
import 'package:eco_coins_mobile_app/views/home/maintenance_screen.dart';
import 'package:eco_coins_mobile_app/views/home/plant_tree_screen.dart';
import 'package:eco_coins_mobile_app/views/splash_screen.dart';

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
          create: (_) => MaintenanceController(databaseService, notificationService),
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
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/plant-tree': (context) => const PlantTreeScreen(),
        '/maintenance': (context) => const MaintenanceScreen(),
      },
    );
  }
}
}
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed = _incrementCounter,
        tooltip = 'Increment',
        child = const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
