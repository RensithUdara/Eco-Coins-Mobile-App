// TEMPORARY MOCK IMPLEMENTATION
// This is a placeholder notification service that doesn't actually use the
// flutter_local_notifications package to avoid build issues.
// We will implement this properly once the dependency issues are resolved.

/// Service class for handling notifications (currently mocked)
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  /// Initialize notification service (mock implementation)
  Future<void> initializeNotifications() async {
    print('Mock notification service initialized');
    // Real implementation will be added later
  }

  /// Show immediate notification (mock implementation)
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    print('Mock notification: $title - $body');
    // Real implementation will be added later
  }

  /// Schedule a notification for tree maintenance (mock implementation)
  Future<void> scheduleMaintenanceNotification({
    required int id,
    required String treeSpecies,
    required DateTime scheduledDate,
    required String maintenanceType,
  }) async {
    print(
        'Mock scheduled notification for $treeSpecies: $maintenanceType on ${scheduledDate.toString()}');
    // Real implementation will be added later
  }

  /// Schedule reminders for upcoming maintenance (mock implementation)
  Future<void> scheduleMaintenanceReminders({
    required int treeId,
    required String treeSpecies,
    required DateTime maintenanceDate,
    required String maintenanceType,
  }) async {
    // Mock implementation just logs the scheduled notifications
    print('Mock maintenance reminders for $treeSpecies scheduled');

    // 7 days before
    final sevenDaysBefore = maintenanceDate.subtract(const Duration(days: 7));
    print('Reminder 1: $maintenanceType on $sevenDaysBefore');

    // 3 days before
    final threeDaysBefore = maintenanceDate.subtract(const Duration(days: 3));
    print('Reminder 2: $maintenanceType on $threeDaysBefore');

    // 1 day before
    final oneDayBefore = maintenanceDate.subtract(const Duration(days: 1));
    print('Reminder 3: $maintenanceType on $oneDayBefore');
  }

  /// Cancel all notifications (mock implementation)
  Future<void> cancelAllNotifications() async {
    print('Mock cancellation of all notifications');
    // Real implementation will be added later
  }

  /// Cancel notification by id (mock implementation)
  Future<void> cancelNotification(int id) async {
    print('Mock cancellation of notification #$id');
    // Real implementation will be added later
  }
}
