import 'dart:io';

import 'package:eco_coins_mobile_app/models/eco_coin_model.dart';
import 'package:eco_coins_mobile_app/models/maintenance_model.dart';
import 'package:eco_coins_mobile_app/models/tree_model.dart';
import 'package:eco_coins_mobile_app/services/database_service.dart';
import 'package:eco_coins_mobile_app/services/image_service.dart';
import 'package:eco_coins_mobile_app/services/notification_service.dart';
import 'package:eco_coins_mobile_app/utils/helpers.dart';
import 'package:flutter/material.dart';

/// State for tree operations
enum TreeOperationState {
  initial,
  loading,
  success,
  error,
}

/// Controller class for handling tree-related operations
class TreeController with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final ImageService _imageService = ImageService();
  final NotificationService _notificationService = NotificationService();

  List<Tree> _trees = [];
  final Map<int, List<Maintenance>> _maintenanceRecords = {};
  TreeOperationState _state = TreeOperationState.initial;
  String? _errorMessage;

  /// Getters
  List<Tree> get trees => _trees;
  TreeOperationState get state => _state;
  String? get errorMessage => _errorMessage;

  /// Get maintenance records for a specific tree
  List<Maintenance> getMaintenanceRecordsForTree(int treeId) {
    return _maintenanceRecords[treeId] ?? [];
  }

  /// Load trees for a user
  Future<void> loadTrees(int userId) async {
    try {
      _state = TreeOperationState.loading;
      notifyListeners();

      // Get trees for user
      _trees = await _databaseService.getTreesByUserId(userId);

      // Get maintenance records for each tree
      for (final Tree tree in _trees) {
        if (tree.id != null) {
          _maintenanceRecords[tree.id!] =
              await _databaseService.getMaintenanceByTreeId(tree.id!);
        }
      }

      _state = TreeOperationState.success;
      notifyListeners();
    } catch (e) {
      _state = TreeOperationState.error;
      _errorMessage = 'Failed to load trees: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Add a new tree
  Future<bool> addTree({
    required int userId,
    required String species,
    required String description,
    required DateTime plantedDate,
    required File photoFile,
  }) async {
    try {
      _state = TreeOperationState.loading;
      notifyListeners();

      // Save image to app directory
      final String photoPath =
          await _imageService.saveImageToAppDirectory(photoFile, 'tree');

      // Calculate coins based on tree species
      final int coinsEarned = Helpers.getTreeBaseCoins(species);

      // Create tree object
      final Tree tree = Tree(
        userId: userId,
        species: species,
        description: description,
        photoPath: photoPath,
        plantedDate: plantedDate,
        coinsEarned: coinsEarned,
      );

      // Save tree to database
      final int treeId = await _databaseService.createTree(tree);

      // Create transaction record
      final EcoCoinTransaction transaction = EcoCoinTransaction(
        userId: userId,
        amount: coinsEarned,
        date: DateTime.now(),
        type: TransactionType.treePlanting,
        treeId: treeId,
      );

      // Save transaction
      await _databaseService.createTransaction(transaction);

      // Update user's coin balance
      await _databaseService.updateUserCoinsBalance(userId, coinsEarned);

      // Add tree to list
      final Tree newTree = tree.copyWith(id: treeId);
      _trees.add(newTree);
      _maintenanceRecords[treeId] = [];

      // Schedule maintenance notifications
      _scheduleMaintenanceNotifications(newTree);

      _state = TreeOperationState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _state = TreeOperationState.error;
      _errorMessage = 'Failed to add tree: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Add maintenance record
  Future<bool> addMaintenanceRecord({
    required int treeId,
    required MaintenanceUpdateType updateType,
  }) async {
    try {
      _state = TreeOperationState.loading;
      notifyListeners();

      // Get tree by id
      final Tree? tree = await _databaseService.getTreeById(treeId);
      if (tree == null) {
        _state = TreeOperationState.error;
        _errorMessage = 'Tree not found';
        notifyListeners();
        return false;
      }

      // Create maintenance record
      final Maintenance maintenance = Maintenance(
        treeId: treeId,
        updateDate: DateTime.now(),
        coinsEarned: updateType.coinsEarned,
        updateType: updateType,
      );

      // Save maintenance record
      final int maintenanceId =
          await _databaseService.createMaintenance(maintenance);

      // Create transaction record
      final EcoCoinTransaction transaction = EcoCoinTransaction(
        userId: tree.userId,
        amount: updateType.coinsEarned,
        date: DateTime.now(),
        type: TransactionType.maintenance,
        treeId: treeId,
        maintenanceId: maintenanceId,
      );

      // Save transaction
      await _databaseService.createTransaction(transaction);

      // Update user's coin balance
      await _databaseService.updateUserCoinsBalance(
          tree.userId, updateType.coinsEarned);

      // Update tree coins earned
      final Tree updatedTree = tree.copyWith(
        coinsEarned: tree.coinsEarned + updateType.coinsEarned,
      );
      await _databaseService.updateTree(updatedTree);

      // Update tree in list
      final int treeIndex = _trees.indexWhere((t) => t.id == treeId);
      if (treeIndex != -1) {
        _trees[treeIndex] = updatedTree;
      }

      // Add maintenance record to list
      final Maintenance newMaintenance =
          maintenance.copyWith(id: maintenanceId);
      if (_maintenanceRecords.containsKey(treeId)) {
        _maintenanceRecords[treeId]!.add(newMaintenance);
      } else {
        _maintenanceRecords[treeId] = [newMaintenance];
      }

      // Schedule next maintenance notification
      _scheduleMaintenanceNotifications(updatedTree);

      _state = TreeOperationState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _state = TreeOperationState.error;
      _errorMessage = 'Failed to add maintenance record: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Get maintenance status for a tree
  MaintenanceStatus getMaintenanceStatus(int treeId) {
    final Tree? tree = _trees.cast<Tree?>().firstWhere(
          (t) => t?.id == treeId,
          orElse: () => null,
        );
    if (tree != null) {
      final List<Maintenance> maintenanceList =
          _maintenanceRecords[treeId] ?? [];
      return Helpers.getMaintenanceStatus(tree, maintenanceList);
    }
    return MaintenanceStatus.upToDate;
  }

  /// Get next maintenance date for a tree
  DateTime? getNextMaintenanceDate(int treeId) {
    final Tree? tree = _trees.cast<Tree?>().firstWhere(
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
    final Tree? tree = _trees.cast<Tree?>().firstWhere(
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

  /// Schedule maintenance notifications for a tree
  void _scheduleMaintenanceNotifications(Tree tree) {
    if (tree.id != null) {
      final List<Maintenance> maintenanceList =
          _maintenanceRecords[tree.id!] ?? [];
      final DateTime? nextMaintenanceDate =
          Helpers.calculateNextMaintenanceDate(tree, maintenanceList);
      final MaintenanceUpdateType? nextUpdateType =
          getNextMaintenanceType(tree.id!);

      if (nextMaintenanceDate != null && nextUpdateType != null) {
        _notificationService.scheduleMaintenanceReminders(
          treeId: tree.id!,
          treeSpecies: tree.species,
          maintenanceDate: nextMaintenanceDate,
          maintenanceType: nextUpdateType.displayText,
        );
      }
    }
  }
}
