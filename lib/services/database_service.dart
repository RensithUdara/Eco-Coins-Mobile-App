import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:eco_coins_mobile_app/utils/constants.dart';
import 'package:eco_coins_mobile_app/models/user_model.dart';
import 'package:eco_coins_mobile_app/models/tree_model.dart';
import 'package:eco_coins_mobile_app/models/maintenance_model.dart';
import 'package:eco_coins_mobile_app/models/eco_coin_model.dart';

/// Service class for handling database operations
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  /// Get the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), DBConstants.dbName);
    return await openDatabase(
      path,
      version: DBConstants.dbVersion,
      onCreate: _createDatabase,
    );
  }

  /// Create database tables
  Future<void> _createDatabase(Database db, int version) async {
    // Users table
    await db.execute('''
    CREATE TABLE ${DBConstants.userTable} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT NOT NULL UNIQUE,
      name TEXT NOT NULL,
      coins_balance INTEGER DEFAULT 0,
      created_at TEXT NOT NULL
    )
    ''');

    // Trees table
    await db.execute('''
    CREATE TABLE ${DBConstants.treeTable} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      species TEXT NOT NULL,
      description TEXT NOT NULL,
      photo_path TEXT NOT NULL,
      planted_date TEXT NOT NULL,
      coins_earned INTEGER DEFAULT 0,
      FOREIGN KEY (user_id) REFERENCES ${DBConstants.userTable} (id) ON DELETE CASCADE
    )
    ''');

    // Maintenance table
    await db.execute('''
    CREATE TABLE ${DBConstants.maintenanceTable} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      tree_id INTEGER NOT NULL,
      update_date TEXT NOT NULL,
      coins_earned INTEGER NOT NULL,
      update_type TEXT NOT NULL,
      FOREIGN KEY (tree_id) REFERENCES ${DBConstants.treeTable} (id) ON DELETE CASCADE
    )
    ''');

    // Transactions table
    await db.execute('''
    CREATE TABLE ${DBConstants.transactionTable} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      amount INTEGER NOT NULL,
      date TEXT NOT NULL,
      type TEXT NOT NULL,
      tree_id INTEGER,
      maintenance_id INTEGER,
      FOREIGN KEY (user_id) REFERENCES ${DBConstants.userTable} (id) ON DELETE CASCADE,
      FOREIGN KEY (tree_id) REFERENCES ${DBConstants.treeTable} (id) ON DELETE SET NULL,
      FOREIGN KEY (maintenance_id) REFERENCES ${DBConstants.maintenanceTable} (id) ON DELETE SET NULL
    )
    ''');
  }

  /// USER OPERATIONS ///

  /// Create a new user
  Future<int> createUser(User user) async {
    final Database db = await database;
    return await db.insert(
      DBConstants.userTable,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get user by email
  Future<User?> getUserByEmail(String email) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      DBConstants.userTable,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  /// Get user by id
  Future<User?> getUserById(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      DBConstants.userTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  /// Update user
  Future<int> updateUser(User user) async {
    final Database db = await database;
    return await db.update(
      DBConstants.userTable,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  /// Update user's coin balance
  Future<void> updateUserCoinsBalance(int userId, int amount) async {
    final Database db = await database;
    await db.rawUpdate(
      'UPDATE ${DBConstants.userTable} SET coins_balance = coins_balance + ? WHERE id = ?',
      [amount, userId],
    );
  }

  /// TREE OPERATIONS ///

  /// Create a new tree
  Future<int> createTree(Tree tree) async {
    final Database db = await database;
    return await db.insert(
      DBConstants.treeTable,
      tree.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all trees for a user
  Future<List<Tree>> getTreesByUserId(int userId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      DBConstants.treeTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'planted_date DESC',
    );

    return List.generate(maps.length, (i) {
      return Tree.fromMap(maps[i]);
    });
  }

  /// Get tree by id
  Future<Tree?> getTreeById(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      DBConstants.treeTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Tree.fromMap(maps.first);
    }
    return null;
  }

  /// Update tree
  Future<int> updateTree(Tree tree) async {
    final Database db = await database;
    return await db.update(
      DBConstants.treeTable,
      tree.toMap(),
      where: 'id = ?',
      whereArgs: [tree.id],
    );
  }

  /// Delete tree
  Future<int> deleteTree(int id) async {
    final Database db = await database;
    return await db.delete(
      DBConstants.treeTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// MAINTENANCE OPERATIONS ///

  /// Create a new maintenance record
  Future<int> createMaintenance(Maintenance maintenance) async {
    final Database db = await database;
    return await db.insert(
      DBConstants.maintenanceTable,
      maintenance.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all maintenance records for a tree
  Future<List<Maintenance>> getMaintenanceByTreeId(int treeId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      DBConstants.maintenanceTable,
      where: 'tree_id = ?',
      whereArgs: [treeId],
      orderBy: 'update_date DESC',
    );

    return List.generate(maps.length, (i) {
      return Maintenance.fromMap(maps[i]);
    });
  }

  /// Get maintenance by id
  Future<Maintenance?> getMaintenanceById(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      DBConstants.maintenanceTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Maintenance.fromMap(maps.first);
    }
    return null;
  }

  /// TRANSACTION OPERATIONS ///

  /// Create a new transaction
  Future<int> createTransaction(EcoCoinTransaction transaction) async {
    final Database db = await database;
    return await db.insert(
      DBConstants.transactionTable,
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all transactions for a user
  Future<List<EcoCoinTransaction>> getTransactionsByUserId(int userId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      DBConstants.transactionTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return EcoCoinTransaction.fromMap(maps[i]);
    });
  }

  /// Get transaction by id
  Future<EcoCoinTransaction?> getTransactionById(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      DBConstants.transactionTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return EcoCoinTransaction.fromMap(maps.first);
    }
    return null;
  }
}