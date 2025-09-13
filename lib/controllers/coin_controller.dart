import 'package:eco_coins_mobile_app/models/eco_coin_model.dart';
import 'package:eco_coins_mobile_app/models/user_model.dart';
import 'package:eco_coins_mobile_app/services/database_service.dart';
import 'package:flutter/material.dart';

/// State for coin operations
enum CoinOperationState {
  initial,
  loading,
  success,
  error,
}

/// Controller class for handling coin-related operations
class CoinController with ChangeNotifier {
  final DatabaseService _databaseService;
  
  CoinController(this._databaseService);

  List<EcoCoinTransaction> _transactions = [];
  CoinOperationState _state = CoinOperationState.initial;
  String? _errorMessage;

  /// Getters
  List<EcoCoinTransaction> get transactions => _transactions;
  CoinOperationState get state => _state;
  String? get errorMessage => _errorMessage;

  /// Load transactions for a user
  Future<void> loadTransactions(int userId) async {
    try {
      _state = CoinOperationState.loading;
      notifyListeners();

      // Get transactions for user
      _transactions = await _databaseService.getTransactionsByUserId(userId);

      _state = CoinOperationState.success;
      notifyListeners();
    } catch (e) {
      _state = CoinOperationState.error;
      _errorMessage = 'Failed to load transactions: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Get total coins earned by type
  int getTotalCoinsByType(TransactionType type) {
    return _transactions
        .where((transaction) => transaction.type == type)
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  /// Get total coins earned
  int getTotalCoins() {
    return _transactions.fold(
        0, (sum, transaction) => sum + transaction.amount);
  }

  /// Get estimated value of coins
  /// In a real app, this might use an exchange rate or some other calculation
  double getEstimatedValue() {
    return getTotalCoins() * 1.0; // 1 coin = $1.00 (example)
  }

  /// Add coins to user
  Future<bool> addCoins({
    required int userId,
    required int amount,
    required TransactionType type,
    int? treeId,
    int? maintenanceId,
  }) async {
    try {
      _state = CoinOperationState.loading;
      notifyListeners();

      // Create transaction
      final EcoCoinTransaction transaction = EcoCoinTransaction(
        userId: userId,
        amount: amount,
        date: DateTime.now(),
        type: type,
        treeId: treeId,
        maintenanceId: maintenanceId,
      );

      // Save transaction
      final int transactionId =
          await _databaseService.createTransaction(transaction);

      // Update user's coin balance
      await _databaseService.updateUserCoinsBalance(userId, amount);

      // Add transaction to list
      final EcoCoinTransaction newTransaction =
          transaction.copyWith(id: transactionId);
      _transactions.add(newTransaction);

      _state = CoinOperationState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _state = CoinOperationState.error;
      _errorMessage = 'Failed to add coins: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Get coin balance for a user
  Future<int> getUserCoinBalance(int userId) async {
    try {
      final User? user = await _databaseService.getUserById(userId);
      return user?.coinsBalance ?? 0;
    } catch (e) {
      _errorMessage = 'Failed to get user coin balance: ${e.toString()}';
      notifyListeners();
      return 0;
    }
  }
}
