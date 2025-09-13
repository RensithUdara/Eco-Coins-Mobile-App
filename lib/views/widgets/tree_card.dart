import 'dart:io';

import 'package:eco_coins_mobile_app/models/tree_model.dart';
import 'package:eco_coins_mobile_app/utils/constants.dart';
import 'package:eco_coins_mobile_app/utils/helpers.dart';
import 'package:flutter/material.dart';

/// Tree card widget for displaying tree information
class TreeCard extends StatelessWidget {
  final Tree tree;
  final String statusText;
  final Color statusColor;
  final VoidCallback? onTap;
  final VoidCallback? onUpdate;
  final bool showUpdateButton;

  const TreeCard({
    super.key,
    required this.tree,
    required this.statusText,
    required this.statusColor,
    this.onTap,
    this.onUpdate,
    this.showUpdateButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTreeImage(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                tree.species,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              tree.id != null
                                  ? 'ID: ${tree.id.toString().padLeft(3, '0')}'
                                  : '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: ColorConstants.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Helpers.formatTreeAge(tree.ageInDays),
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 14,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (showUpdateButton) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildUpdateButton(),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              _buildCoinsRow(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build tree image widget
  Widget _buildTreeImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorConstants.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _getTreeImage(),
      ),
    );
  }

  /// Get tree image from path
  Widget _getTreeImage() {
    try {
      return Image.file(
        File(tree.photoPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: ColorConstants.primary.withOpacity(0.1),
            child: const Icon(
              Icons.nature,
              size: 40,
              color: ColorConstants.primary,
            ),
          );
        },
      );
    } catch (e) {
      return Container(
        color: ColorConstants.primary.withOpacity(0.1),
        child: const Icon(
          Icons.nature,
          size: 40,
          color: ColorConstants.primary,
        ),
      );
    }
  }

  /// Build update button widget
  Widget _buildUpdateButton() {
    return ElevatedButton(
      onPressed: onUpdate,
      style: ElevatedButton.styleFrom(
        backgroundColor: statusColor,
        foregroundColor: _getButtonTextColor(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      child: const Text('Update'),
    );
  }

  /// Get button text color based on status color
  Color _getButtonTextColor() {
    // For yellow buttons, use black text for better contrast
    if (statusColor == ColorConstants.warning) {
      return Colors.black;
    }
    return Colors.white;
  }

  /// Build coins row widget
  Widget _buildCoinsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: ColorConstants.textPrimary,
          ),
        ),
      ],
    );
  }
}
