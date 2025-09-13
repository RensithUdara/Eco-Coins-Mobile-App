import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eco_coins_mobile_app/controllers/auth_controller.dart';
import 'package:eco_coins_mobile_app/controllers/tree_controller.dart';
import 'package:eco_coins_mobile_app/controllers/coin_controller.dart';
import 'package:eco_coins_mobile_app/models/tree_model.dart';
import 'package:eco_coins_mobile_app/models/eco_coin_model.dart';
import 'package:eco_coins_mobile_app/utils/constants.dart';
import 'package:eco_coins_mobile_app/utils/helpers.dart';
import 'package:eco_coins_mobile_app/views/widgets/coin_display.dart';
import 'package:eco_coins_mobile_app/views/widgets/tree_card.dart';
import 'package:eco_coins_mobile_app/views/widgets/custom_button.dart';

/// Dashboard screen showing user's trees and coins
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Load user data, trees, and transactions
  Future<void> _loadData() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final treeController = Provider.of<TreeController>(context, listen: false);
    final coinController = Provider.of<CoinController>(context, listen: false);

    if (authController.currentUser != null && authController.currentUser!.id != null) {
      await treeController.loadTrees(authController.currentUser!.id!);
      await coinController.loadTransactions(authController.currentUser!.id!);
      await authController.refreshUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserGreeting(),
              _buildCoinBalance(),
              _buildStatistics(),
              _buildPlantationHistoryHeader(),
              _buildTreesList(),
              const SizedBox(height: 80), // Space for floating action button
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  /// Build user greeting section
  Widget _buildUserGreeting() {
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        final user = authController.currentUser;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Hello, ${user?.name ?? 'User'}!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ColorConstants.textPrimary,
            ),
          ),
        );
      },
    );
  }

  /// Build coin balance section
  Widget _buildCoinBalance() {
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        final user = authController.currentUser;
        return CoinDisplay(
          coinBalance: user?.coinsBalance ?? 0,
          isLarge: true,
        );
      },
    );
  }

  /// Build statistics section
  Widget _buildStatistics() {
    return Consumer2<TreeController, CoinController>(
      builder: (context, treeController, coinController, _) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: CoinStatistics(
            treesPlanted: treeController.trees.length,
            estimatedValue: coinController.getTotalCoins(),
          ),
        );
      },
    );
  }

  /// Build plantation history header
  Widget _buildPlantationHistoryHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Plantation History',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: ColorConstants.textPrimary,
        ),
      ),
    );
  }

  /// Build trees list section
  Widget _buildTreesList() {
    return Consumer<TreeController>(
      builder: (context, treeController, _) {
        if (treeController.state == TreeOperationState.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (treeController.trees.isEmpty) {
          return _buildEmptyTreesMessage();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: treeController.trees.length,
          itemBuilder: (context, index) {
            final tree = treeController.trees[index];
            return _buildTreeCard(tree, treeController);
          },
        );
      },
    );
  }

  /// Build a message for when there are no trees
  Widget _buildEmptyTreesMessage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.nature,
              size: 64,
              color: ColorConstants.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '0 trees planted',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColorConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'plant trees to earn EcoCoins!',
              style: TextStyle(
                fontSize: 16,
                color: ColorConstants.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Plant Your First Tree',
              onPressed: () {
                Navigator.pushNamed(context, AppConstants.plantTreeRoute);
              },
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }

  /// Build a tree card for a specific tree
  Widget _buildTreeCard(Tree tree, TreeController treeController) {
    final maintenanceStatus = treeController.getMaintenanceStatus(tree.id!);
    final statusColor = Helpers.getMaintenanceStatusColor(maintenanceStatus);
    final statusText = maintenanceStatus == MaintenanceStatus.upToDate
        ? 'Up to date'
        : '${maintenanceStatus.toString().split('.').last} maintenance';

    return TreeCard(
      tree: tree,
      statusText: statusText,
      statusColor: statusColor,
      onTap: () => _showTreeDetails(tree),
      onUpdate: maintenanceStatus != MaintenanceStatus.upToDate
          ? () => Navigator.pushNamed(context, AppConstants.maintainRoute, arguments: tree)
          : null,
      showUpdateButton: maintenanceStatus != MaintenanceStatus.upToDate,
    );
  }

  /// Build floating action buttons
  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'maintain',
          onPressed: () {
            Navigator.pushNamed(context, AppConstants.maintainRoute);
          },
          backgroundColor: ColorConstants.warning,
          child: const Icon(Icons.update),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          heroTag: 'plant',
          onPressed: () {
            Navigator.pushNamed(context, AppConstants.plantTreeRoute);
          },
          backgroundColor: ColorConstants.primary,
          child: const Icon(Icons.add),
        ),
      ],
    );
  }

  /// Show tree details dialog
  void _showTreeDetails(Tree tree) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tree.species,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Planted on: ${Helpers.formatDate(tree.plantedDate)}',
                style: TextStyle(
                  fontSize: 16,
                  color: ColorConstants.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Age: ${Helpers.formatTreeAge(tree.ageInDays)}',
                style: TextStyle(
                  fontSize: 16,
                  color: ColorConstants.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Description:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tree.description,
                style: TextStyle(
                  fontSize: 16,
                  color: ColorConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Coins Earned:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColorConstants.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on,
                        color: ColorConstants.secondary,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${tree.coinsEarned}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Close',
                onPressed: () => Navigator.pop(context),
                type: ButtonType.secondary,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Handle logout button press
  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthController>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}