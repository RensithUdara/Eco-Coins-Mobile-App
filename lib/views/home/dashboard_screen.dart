import 'package:eco_coins_mobile_app/controllers/auth_controller.dart';
import 'package:eco_coins_mobile_app/controllers/coin_controller.dart';
import 'package:eco_coins_mobile_app/controllers/tree_controller.dart';
import 'package:eco_coins_mobile_app/models/tree_model.dart';
import 'package:eco_coins_mobile_app/utils/constants.dart';
import 'package:eco_coins_mobile_app/utils/helpers.dart';
import 'package:eco_coins_mobile_app/views/widgets/coin_display.dart';
import 'package:eco_coins_mobile_app/views/widgets/custom_button.dart';
import 'package:eco_coins_mobile_app/views/widgets/tree_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

    if (authController.currentUser != null &&
        authController.currentUser!.id != null) {
      await treeController.fetchUserTrees(authController.currentUser!.id!);
      await coinController.loadTransactions(authController.currentUser!.id!);
      await authController.refreshUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3,
                color: Color.fromRGBO(0, 0, 0, 0.3),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: ColorConstants.primary,
        backgroundColor: Colors.white,
        child: Stack(
          children: [
            // Header gradient background
            Container(
              height: 260,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColorConstants.primaryDark,
                    ColorConstants.primary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: -30,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserGreeting(),
                    _buildCoinBalance(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: _buildStatistics(),
                    ),
                    const SizedBox(height: 16),
                    _buildActionButtons(),
                    _buildSectionTitle('Plantation History', Icons.nature),
                    _buildTreesList(),
                    const SizedBox(
                        height: 80), // Space for floating action button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  /// Build section title
  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorConstants.primaryLight.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: ColorConstants.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ColorConstants.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Build action buttons for quick access to features
  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            'Plant Tree',
            Icons.eco,
            ColorConstants.primary,
            () => Navigator.pushNamed(context, AppConstants.plantTreeRoute),
          ),
          _buildActionButton(
            'Maintenance',
            Icons.update,
            ColorConstants.secondary,
            () => Navigator.pushNamed(context, AppConstants.maintainRoute),
          ),
          _buildActionButton(
            'Activity',
            Icons.history,
            ColorConstants.info,
            () => _showTransactionHistory(),
          ),
        ],
      ),
    );
  }

  /// Build a single action button
  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show transaction history modal
  void _showTransactionHistory() {
    // Implement transaction history modal
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaction history feature coming soon'),
      ),
    );
  }

  /// Build user greeting section
  Widget _buildUserGreeting() {
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        final user = authController.currentUser;
        final now = DateTime.now();
        String greeting = 'Good morning';

        if (now.hour >= 12 && now.hour < 17) {
          greeting = 'Good afternoon';
        } else if (now.hour >= 17) {
          greeting = 'Good evening';
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    user?.name ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.waving_hand,
                    color: ColorConstants.secondary,
                    size: 20,
                  ),
                ],
              ),
            ],
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
    return const Padding(
      padding: EdgeInsets.all(16.0),
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
            const Text(
              '0 trees planted',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColorConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
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
          ? () => Navigator.pushNamed(context, AppConstants.maintainRoute,
              arguments: tree)
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
                style: const TextStyle(
                  fontSize: 16,
                  color: ColorConstants.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Age: ${Helpers.formatTreeAge(tree.ageInDays)}',
                style: const TextStyle(
                  fontSize: 16,
                  color: ColorConstants.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
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
                style: const TextStyle(
                  fontSize: 16,
                  color: ColorConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Coins Earned:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColorConstants.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: ColorConstants.secondary,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${tree.coinsEarned}',
                        style: const TextStyle(
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
