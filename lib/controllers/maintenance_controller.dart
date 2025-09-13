import 'package:eco_coins_mobile_app/models/maintenance_model.dart';
import 'package:eco_coins_mobile_app/models/tree_model.dart';
import 'package:eco_coins_mobile_app/services/database_service.dart';
import 'package:eco_coins_mobile_app/services/notification_service.dart';
import 'package:eco_coins_mobile_app/utils/helpers.dart';
import 'package:flutter/material.dart';

/// State for maintenance operations
enum MaintenanceOperationState {
  initial,
  loading,
  success,
  error,
}

/// Controller class for handling maintenance-related operations
class MaintenanceController with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  List<Tree> _treesForMaintenance = [];
  Map<int, List<Maintenance>> _maintenanceRecords = {};
  Map<int, MaintenanceStatus> _maintenanceStatuses = {};
  MaintenanceOperationState _state = MaintenanceOperationState.initial;
  String? _errorMessage;

  /// Getters
  List<Tree> get treesForMaintenance => _treesForMaintenance;
  MaintenanceOperationState get state => _state;
  String? get errorMessage => _errorMessage;
  
  /// Add maintenance record
  Future<bool> addMaintenance({
    required int userId,
    required int treeId,
    required MaintenanceActivity activity,
    required String notes,
    required DateTime date,
    required dynamic photoFile,
  }) async {
    _state = MaintenanceOperationState.loading;
    notifyListeners();
    
    try {
      // Implementation will come later
      await Future.delayed(const Duration(seconds: 2));
      _state = MaintenanceOperationState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _state = MaintenanceOperationState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Get maintenance records for a tree
  List<Maintenance> getMaintenanceRecordsForTree(int treeId) {
    return _maintenanceRecords[treeId] ?? [];
  }

  /// Get maintenance status for a tree
  MaintenanceStatus getMaintenanceStatusForTree(int treeId) {
    return _maintenanceStatuses[treeId] ?? MaintenanceStatus.upToDate;
  }

  /// Load trees for maintenance
  Future<void> loadTreesForMaintenance(int userId) async {
    try {
      _state = MaintenanceOperationState.loading;
      notifyListeners();

      // Get trees for user
      final List<Tree> allTrees =
          await _databaseService.getTreesByUserId(userId);
      _treesForMaintenance = [];
      _maintenanceRecords = {};
      _maintenanceStatuses = {};

      // Get maintenance records and calculate status for each tree
      for (final Tree tree in allTrees) {
        if (tree.id != null) {
          final List<Maintenance> maintenance =
              await _databaseService.getMaintenanceByTreeId(tree.id!);
          _maintenanceRecords[tree.id!] = maintenance;

          // Calculate maintenance status
          final MaintenanceStatus status =
              Helpers.getMaintenanceStatus(tree, maintenance);
          _maintenanceStatuses[tree.id!] = status;

          // Add tree to list if it's due for maintenance
          if (status != MaintenanceStatus.upToDate) {
            _treesForMaintenance.add(tree);
          }
        }
      }

      // Sort trees by maintenance urgency
      _treesForMaintenance.sort((a, b) {
        final int statusA = _getMaintenanceStatusPriority(
            _maintenanceStatuses[a.id] ?? MaintenanceStatus.upToDate);
        final int statusB = _getMaintenanceStatusPriority(
            _maintenanceStatuses[b.id] ?? MaintenanceStatus.upToDate);
        return statusA.compareTo(statusB);
      });

      _state = MaintenanceOperationState.success;
      notifyListeners();
    } catch (e) {
      _state = MaintenanceOperationState.error;
      _errorMessage = 'Failed to load trees for maintenance: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Get next maintenance date for a tree
  DateTime? getNextMaintenanceDate(int treeId) {
    final Tree? tree = _treesForMaintenance.cast<Tree?>().firstWhere(
          (t) => t?.id == treeId,
          orElse: () => null,
        );
    if (tree != null) {
      final List<Maintenance> maintenanceList =
          _maintenanceRecords[treeId] ?? [];
      return Helpers.calculateNextMaintenanceDate(tree, maintenanceList);
    }
    return null;
  }

  /// Get next maintenance type for a tree
  MaintenanceUpdateType? getNextMaintenanceType(int treeId) {
    final Tree? tree = _treesForMaintenance.cast<Tree?>().firstWhere(
          (t) => t?.id == treeId,
          orElse: () => null,
        );
    if (tree != null) {
      final int treeAgeDays = tree.ageInDays;

      if (treeAgeDays < MaintenanceUpdateType.oneMonth.days) {
        return MaintenanceUpdateType.oneMonth;
      } else if (treeAgeDays < MaintenanceUpdateType.threeMonths.days) {
        return MaintenanceUpdateType.threeMonths;
      } else if (treeAgeDays < MaintenanceUpdateType.sixMonths.days) {
        return MaintenanceUpdateType.sixMonths;
      } else {
        return MaintenanceUpdateType.oneYear;
      }
    }
    return null;
  }

  /// Get days until next maintenance
  int? getDaysUntilNextMaintenance(int treeId) {
    final DateTime? nextDate = getNextMaintenanceDate(treeId);
    if (nextDate != null) {
      return nextDate.difference(DateTime.now()).inDays;
    }
    return null;
  }

  /// Get a formatted string for the next maintenance date
  String getNextMaintenanceDateText(int treeId) {
    final int? days = getDaysUntilNextMaintenance(treeId);
    if (days == null) {
      return 'Unknown';
    }

    if (days < 0) {
      return 'Overdue by ${-days} days';
    } else if (days == 0) {
      return 'Due today';
    } else if (days == 1) {
      return 'Due tomorrow';
    } else if (days < 30) {
      return 'Due in $days days';
    } else {
      return 'Due in ${(days / 30).floor()} months';
    }
  }

  /// Helper function to get priority value for maintenance status
  int _getMaintenanceStatusPriority(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.overdue:
        return 1;
      case MaintenanceStatus.dueThisWeek:
        return 2;
      case MaintenanceStatus.dueSoon:
        return 3;
      case MaintenanceStatus.upToDate:
        return 4;
    }
  }
}
