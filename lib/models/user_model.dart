/// Model class for User
class User {
  final int? id;
  final String email;
  final String name;
  int coinsBalance;
  final DateTime createdAt;

  User({
    this.id,
    required this.email,
    required this.name,
    this.coinsBalance = 0,
    required this.createdAt,
  });

  /// Factory method to create a User object from a map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      coinsBalance: map['coins_balance'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  /// Method to convert User object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'coins_balance': coinsBalance,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Method to copy User object with updated values
  User copyWith({
    int? id,
    String? email,
    String? name,
    int? coinsBalance,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      coinsBalance: coinsBalance ?? this.coinsBalance,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, coinsBalance: $coinsBalance, createdAt: $createdAt)';
  }
}