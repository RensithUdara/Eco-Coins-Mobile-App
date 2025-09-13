/// Model class for Tree
class Tree {
  final int? id;
  final int userId;
  final String species;
  final String description;
  final String photoPath;
  final DateTime plantedDate;
  int coinsEarned;

  Tree({
    this.id,
    required this.userId,
    required this.species,
    required this.description,
    required this.photoPath,
    required this.plantedDate,
    this.coinsEarned = 0,
  });

  /// Factory method to create a Tree object from a map
  factory Tree.fromMap(Map<String, dynamic> map) {
    return Tree(
      id: map['id'],
      userId: map['user_id'],
      species: map['species'],
      description: map['description'],
      photoPath: map['photo_path'],
      plantedDate: DateTime.parse(map['planted_date']),
      coinsEarned: map['coins_earned'],
    );
  }

  /// Method to convert Tree object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'species': species,
      'description': description,
      'photo_path': photoPath,
      'planted_date': plantedDate.toIso8601String(),
      'coins_earned': coinsEarned,
    };
  }

  /// Method to copy Tree object with updated values
  Tree copyWith({
    int? id,
    int? userId,
    String? species,
    String? description,
    String? photoPath,
    DateTime? plantedDate,
    int? coinsEarned,
  }) {
    return Tree(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      species: species ?? this.species,
      description: description ?? this.description,
      photoPath: photoPath ?? this.photoPath,
      plantedDate: plantedDate ?? this.plantedDate,
      coinsEarned: coinsEarned ?? this.coinsEarned,
    );
  }

  /// Calculate tree age in days
  int get ageInDays {
    return DateTime.now().difference(plantedDate).inDays;
  }
  
  /// Calculate tree age in months
  double get ageInMonths {
    return ageInDays / 30;
  }

  @override
  String toString() {
    return 'Tree(id: $id, userId: $userId, species: $species, plantedDate: $plantedDate, coinsEarned: $coinsEarned)';
  }
}