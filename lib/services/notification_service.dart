import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Service class for handling notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  /// Initialize notification service
  Future<void> initializeNotifications() async {
    // Initialize timezone
    tz_data.initializeTimeZones();

    // Android initialization settings
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const IOSInitializationSettings iosInitializationSettings =
        IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Initialization settings for both platforms
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    // Initialize plugin
    await _notificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: _onSelectNotification,
    );
  }

  /// Handle notification selection
  Future<void> _onSelectNotification(String? payload) async {
    // Handle notification tap
    if (payload != null) {
      // Handle payload
    }
  }

  /// Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'eco_coins_channel',
      'Eco Coins Notifications',
      channelDescription: 'Notifications for Eco Coins app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const IOSNotificationDetails iosDetails = IOSNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Schedule a notification for tree maintenance
  Future<void> scheduleMaintenanceNotification({
    required int id,
    required String treeSpecies,
    required DateTime scheduledDate,
    required String maintenanceType,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'eco_coins_maintenance_channel',
      'Maintenance Notifications',
      channelDescription: 'Notifications for tree maintenance',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const IOSNotificationDetails iosDetails = IOSNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      'Maintenance Reminder',
      'Your $treeSpecies tree needs a $maintenanceType. Earn more EcoCoins!',
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'maintenance_$id',
    );
  }

  /// Schedule reminders for upcoming maintenance
  Future<void> scheduleMaintenanceReminders({
    required int treeId,
    required String treeSpecies,
    required DateTime maintenanceDate,
    required String maintenanceType,
  }) async {
    // 7 days before
    await scheduleMaintenanceNotification(
      id: treeId * 100 + 1,
      treeSpecies: treeSpecies,
      scheduledDate: maintenanceDate.subtract(const Duration(days: 7)),
      maintenanceType: maintenanceType,
    );

    // 3 days before
    await scheduleMaintenanceNotification(
      id: treeId * 100 + 2,
      treeSpecies: treeSpecies,
      scheduledDate: maintenanceDate.subtract(const Duration(days: 3)),
      maintenanceType: maintenanceType,
    );

    // 1 day before
    await scheduleMaintenanceNotification(
      id: treeId * 100 + 3,
      treeSpecies: treeSpecies,
      scheduledDate: maintenanceDate.subtract(const Duration(days: 1)),
      maintenanceType: maintenanceType,
    );
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Cancel notification by id
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
