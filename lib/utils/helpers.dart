import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eco_coins_mobile_app/models/tree_model.dart';
import 'package:eco_coins_mobile_app/models/maintenance_model.dart';

/// Helper functions used throughout the app
class Helpers {
  /// Format a DateTime object to a human-readable date string
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Format a DateTime object to a human-readable date and time string
  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  /// Calculate the days since a given date
  static int daysSince(DateTime date) {
    return DateTime.now().difference(date).inDays;
  }

  /// Calculate the next maintenance date for a tree based on its age
  static DateTime? calculateNextMaintenanceDate(Tree tree, List<Maintenance> maintenanceHistory) {
    final int treeAgeDays = tree.ageInDays;
    
    // If tree is less than a month old, return 1-month update date
    if (treeAgeDays < MaintenanceUpdateType.oneMonth.days) {
      return tree.plantedDate.add(Duration(days: MaintenanceUpdateType.oneMonth.days));
    }
    
    // If tree is less than three months old, return 3-month update date
    if (treeAgeDays < MaintenanceUpdateType.threeMonths.days) {
      return tree.plantedDate.add(Duration(days: MaintenanceUpdateType.threeMonths.days));
    }
    
    // If tree is less than six months old, return 6-month update date
    if (treeAgeDays < MaintenanceUpdateType.sixMonths.days) {
      return tree.plantedDate.add(Duration(days: MaintenanceUpdateType.sixMonths.days));
    }
    
    // If tree is less than a year old, return 1-year update date
    if (treeAgeDays < MaintenanceUpdateType.oneYear.days) {
      return tree.plantedDate.add(Duration(days: MaintenanceUpdateType.oneYear.days));
    }
    
    // For trees older than a year, calculate the next yearly update date
    final int yearsSincePlanting = (treeAgeDays / 365).floor();
    return tree.plantedDate.add(Duration(days: (yearsSincePlanting + 1) * 365));
  }

  /// Get the maintenance status for a tree
  static MaintenanceStatus getMaintenanceStatus(Tree tree, List<Maintenance> maintenanceHistory) {
    final DateTime? nextDate = calculateNextMaintenanceDate(tree, maintenanceHistory);
    
    if (nextDate == null) {
      return MaintenanceStatus.upToDate;
    }
    
    final int daysUntilNextUpdate = nextDate.difference(DateTime.now()).inDays;
    
    if (daysUntilNextUpdate < 0) {
      return MaintenanceStatus.overdue;
    } else if (daysUntilNextUpdate <= 7) {
      return MaintenanceStatus.dueThisWeek;
    } else if (daysUntilNextUpdate <= 14) {
      return MaintenanceStatus.dueSoon;
    } else {
      return MaintenanceStatus.upToDate;
    }
  }

  /// Get the appropriate color for a maintenance status
  static Color getMaintenanceStatusColor(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.overdue:
        return Colors.red;
      case MaintenanceStatus.dueThisWeek:
        return Colors.orange;
      case MaintenanceStatus.dueSoon:
        return Colors.yellow;
      case MaintenanceStatus.upToDate:
        return Colors.green;
    }
  }

  /// Format tree age in a human-readable string
  static String formatTreeAge(int days) {
    if (days < 30) {
      return '$days days old';
    } else if (days < 365) {
      final int months = (days / 30).floor();
      return '$months month${months > 1 ? 's' : ''} old';
    } else {
      final double years = days / 365;
      return '${years.toStringAsFixed(1)} year${years >= 1.1 ? 's' : ''} old';
    }
  }

  /// Show a snackbar with a message
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Validate an email address
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Get coins earned for a tree based on its species
  static int getTreeBaseCoins(String species) {
    // This can be expanded based on different tree species
    switch (species.toLowerCase()) {
      case 'mango':
        return 100;
      case 'coconut':
        return 120;
      case 'oak':
        return 150;
      case 'pine':
        return 130;
      default:
        return 100;
    }
  }
}

/// Enum for maintenance status
enum MaintenanceStatus {
  overdue,
  dueThisWeek,
  dueSoon,
  upToDate,
}