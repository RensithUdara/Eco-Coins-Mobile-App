/// Enum for maintenance update types
enum MaintenanceUpdateType {
  oneMonth,
  threeMonths,
  sixMonths,
  oneYear,
}

/// Extension on MaintenanceUpdateType
extension MaintenanceUpdateTypeExtension on MaintenanceUpdateType {
  /// Returns the number of days for each update type
  int get days {
    switch (this) {
      case MaintenanceUpdateType.oneMonth:
        return 30;
      case MaintenanceUpdateType.threeMonths:
        return 90;
      case MaintenanceUpdateType.sixMonths:
        return 180;
      case MaintenanceUpdateType.oneYear:
        return 365;
    }
  }

  /// Returns the coins earned for each update type
  int get coinsEarned {
    switch (this) {
      case MaintenanceUpdateType.oneMonth:
        return 20;
      case MaintenanceUpdateType.threeMonths:
        return 30;
      case MaintenanceUpdateType.sixMonths:
        return 40;
      case MaintenanceUpdateType.oneYear:
        return 50;
    }
  }

  /// Returns the string representation of the update type
  String get displayText {
    switch (this) {
      case MaintenanceUpdateType.oneMonth:
        return '1-Month Update';
      case MaintenanceUpdateType.threeMonths:
        return '3-Month Update';
      case MaintenanceUpdateType.sixMonths:
        return '6-Month Update';
      case MaintenanceUpdateType.oneYear:
        return '1-Year Update';
    }
  }

  /// Returns the maintenance update type from a string
  static MaintenanceUpdateType fromString(String value) {
    switch (value.toLowerCase()) {
      case '1-month update':
        return MaintenanceUpdateType.oneMonth;
      case '3-month update':
        return MaintenanceUpdateType.threeMonths;
      case '6-month update':
        return MaintenanceUpdateType.sixMonths;
      case '1-year update':
        return MaintenanceUpdateType.oneYear;
      default:
        throw ArgumentError('Invalid maintenance update type: $value');
    }
  }
}

/// Model class for Maintenance
class Maintenance {
  final int? id;
  final int treeId;
  final DateTime updateDate;
  final int coinsEarned;
  final MaintenanceUpdateType updateType;

  Maintenance({
    this.id,
    required this.treeId,
    required this.updateDate,
    required this.coinsEarned,
    required this.updateType,
  });

  /// Factory method to create a Maintenance object from a map
  factory Maintenance.fromMap(Map<String, dynamic> map) {
    return Maintenance(
      id: map['id'],
      treeId: map['tree_id'],
      updateDate: DateTime.parse(map['update_date']),
      coinsEarned: map['coins_earned'],
      updateType: MaintenanceUpdateTypeExtension.fromString(map['update_type']),
    );
  }

  /// Method to convert Maintenance object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tree_id': treeId,
      'update_date': updateDate.toIso8601String(),
      'coins_earned': coinsEarned,
      'update_type': updateType.displayText,
    };
  }

  /// Method to copy Maintenance object with updated values
  Maintenance copyWith({
    int? id,
    int? treeId,
    DateTime? updateDate,
    int? coinsEarned,
    MaintenanceUpdateType? updateType,
  }) {
    return Maintenance(
      id: id ?? this.id,
      treeId: treeId ?? this.treeId,
      updateDate: updateDate ?? this.updateDate,
      coinsEarned: coinsEarned ?? this.coinsEarned,
      updateType: updateType ?? this.updateType,
    );
  }

  @override
  String toString() {
    return 'Maintenance(id: $id, treeId: $treeId, updateDate: $updateDate, coinsEarned: $coinsEarned, updateType: ${updateType.displayText})';
  }
}