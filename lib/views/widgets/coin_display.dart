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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isLarge ? 24.0 : 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              coinBalance.toString(),
              style: TextStyle(
                fontSize: isLarge ? 48 : 32,
                fontWeight: FontWeight.bold,
                color: ColorConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'EcoCoins Balance',
              style: TextStyle(
                fontSize: isLarge ? 18 : 16,
                color: ColorConstants.textSecondary,
              ),
            ),
          ],
        ),
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
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            treesPlanted.toString(),
            'Trees Planted',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            estimatedValue.toString(),
            'Est. Value',
          ),
        ),
      ],
    );
  }

  /// Build a statistic card
  Widget _buildStatCard(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: ColorConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: ColorConstants.textSecondary,
          ),
        ),
      ],
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
