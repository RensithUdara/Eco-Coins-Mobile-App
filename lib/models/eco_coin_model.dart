/// Enum for transaction types
enum TransactionType {
  treePlanting,
  maintenance,
}

/// Extension on TransactionType
extension TransactionTypeExtension on TransactionType {
  String get displayText {
    switch (this) {
      case TransactionType.treePlanting:
        return 'Tree Planting';
      case TransactionType.maintenance:
        return 'Maintenance';
    }
  }

  /// Returns the transaction type from a string
  static TransactionType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'tree planting':
        return TransactionType.treePlanting;
      case 'maintenance':
        return TransactionType.maintenance;
      default:
        throw ArgumentError('Invalid transaction type: $value');
    }
  }
}

/// Model class for EcoCoin transaction
class EcoCoinTransaction {
  final int? id;
  final int userId;
  final int amount;
  final DateTime date;
  final TransactionType type;
  final int? treeId;
  final int? maintenanceId;

  EcoCoinTransaction({
    this.id,
    required this.userId,
    required this.amount,
    required this.date,
    required this.type,
    this.treeId,
    this.maintenanceId,
  });

  /// Factory method to create an EcoCoinTransaction object from a map
  factory EcoCoinTransaction.fromMap(Map<String, dynamic> map) {
    return EcoCoinTransaction(
      id: map['id'],
      userId: map['user_id'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      type: TransactionTypeExtension.fromString(map['type']),
      treeId: map['tree_id'],
      maintenanceId: map['maintenance_id'],
    );
  }

  /// Method to convert EcoCoinTransaction object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.displayText,
      'tree_id': treeId,
      'maintenance_id': maintenanceId,
    };
  }

  /// Method to copy EcoCoinTransaction object with updated values
  EcoCoinTransaction copyWith({
    int? id,
    int? userId,
    int? amount,
    DateTime? date,
    TransactionType? type,
    int? treeId,
    int? maintenanceId,
  }) {
    return EcoCoinTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      treeId: treeId ?? this.treeId,
      maintenanceId: maintenanceId ?? this.maintenanceId,
    );
  }

  @override
  String toString() {
    return 'EcoCoinTransaction(id: $id, userId: $userId, amount: $amount, date: $date, type: ${type.displayText})';
  }
}