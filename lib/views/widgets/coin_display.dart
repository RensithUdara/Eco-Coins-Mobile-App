import 'package:eco_coins_mobile_app/utils/constants.dart';
import 'package:flutter/material.dart';

/// Coin display widget for showing coin balance
class CoinDisplay extends StatelessWidget {
  final int coinBalance;
  final bool isLarge;

  const CoinDisplay({
    super.key,
    required this.coinBalance,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
      child: Stack(
        children: [
          // Main card
          Container(
            margin: const EdgeInsets.only(top: 15),
            padding: EdgeInsets.fromLTRB(
                20, isLarge ? 30.0 : 20.0, 20, isLarge ? 24.0 : 18.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Balance',
                          style: TextStyle(
                            fontSize: 14,
                            color: ColorConstants.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              coinBalance.toString(),
                              style: TextStyle(
                                fontSize: isLarge ? 36 : 28,
                                fontWeight: FontWeight.bold,
                                color: ColorConstants.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'EcoCoins',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: ColorConstants.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ColorConstants.secondaryLight.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        AssetPaths.coinIcon,
                        height: isLarge ? 32 : 24,
                        width: isLarge ? 32 : 24,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                          Icons.monetization_on,
                          color: ColorConstants.secondary,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Top decoration with pattern
          Positioned(
            top: 0,
            left: 30,
            right: 30,
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                color: ColorConstants.secondaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < 8; i++)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Coin statistics widget for displaying tree and value statistics
class CoinStatistics extends StatelessWidget {
  final int treesPlanted;
  final int estimatedValue;

  const CoinStatistics({
    super.key,
    required this.treesPlanted,
    required this.estimatedValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              context,
              treesPlanted.toString(),
              'Trees Planted',
              Icons.nature,
              ColorConstants.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              context,
              estimatedValue.toString(),
              'Est. Value',
              Icons.trending_up,
              ColorConstants.info,
            ),
          ),
        ],
      ),
    );
  }

  /// Build a statistic card
  Widget _buildStatCard(BuildContext context, String value, String label,
      IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: ColorConstants.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Coin transaction item widget
class CoinTransactionItem extends StatelessWidget {
  final String title;
  final String date;
  final int amount;
  final IconData icon;

  const CoinTransactionItem({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: ColorConstants.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: ColorConstants.primary,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(date),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.monetization_on,
            color: ColorConstants.secondary,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '+$amount',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: ColorConstants.primary,
            ),
          ),
        ],
      ),
    );
  }
}
