import 'package:eco_coins_mobile_app/utils/constants.dart';
import 'package:flutter/material.dart';

/// Privacy Settings Screen allows users to manage their privacy preferences
class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  // Privacy settings options
  bool _locationServices = true;
  bool _dataCollection = true;
  bool _profileVisibility = true;
  bool _achievementsPublic = true;
  bool _marketingEmails = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
        backgroundColor: ColorConstants.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header with information about privacy
            _buildHeader(),

            // Settings options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildSettingsCategory('Location & Data'),
                  _buildSwitchTile(
                    title: 'Location Services',
                    subtitle:
                        'Allow app to access your location for tree planting verification',
                    value: _locationServices,
                    onChanged: (value) {
                      setState(() {
                        _locationServices = value;
                      });
                    },
                  ),
                  _buildSwitchTile(
                    title: 'Data Collection',
                    subtitle:
                        'Allow collection of usage data to improve app experience',
                    value: _dataCollection,
                    onChanged: (value) {
                      setState(() {
                        _dataCollection = value;
                      });
                    },
                  ),
                  const Divider(height: 32),
                  _buildSettingsCategory('Profile & Visibility'),
                  _buildSwitchTile(
                    title: 'Public Profile',
                    subtitle:
                        'Make your profile visible to other eco-enthusiasts',
                    value: _profileVisibility,
                    onChanged: (value) {
                      setState(() {
                        _profileVisibility = value;
                      });
                    },
                  ),
                  _buildSwitchTile(
                    title: 'Public Achievements',
                    subtitle: 'Share your eco achievements with the community',
                    value: _achievementsPublic,
                    onChanged: (value) {
                      setState(() {
                        _achievementsPublic = value;
                      });
                    },
                  ),
                  const Divider(height: 32),
                  _buildSettingsCategory('Communications'),
                  _buildSwitchTile(
                    title: 'Marketing Emails',
                    subtitle:
                        'Receive updates about new features and promotions',
                    value: _marketingEmails,
                    onChanged: (value) {
                      setState(() {
                        _marketingEmails = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildDataManagementSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the header section with privacy information
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ColorConstants.primary,
            ColorConstants.primaryLight,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Privacy Matters',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Control how your information is used within the Eco Coins app.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a category heading for settings
  Widget _buildSettingsCategory(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          color: ColorConstants.primaryDark,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Builds a switch tile for toggling settings
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: ColorConstants.primary,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      ),
    );
  }

  /// Builds the data management section with buttons
  Widget _buildDataManagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingsCategory('Data Management'),
        Card(
          elevation: 0,
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildActionButton(
                  title: 'Download My Data',
                  icon: Icons.download_rounded,
                  color: ColorConstants.info,
                  onTap: () {
                    _showSnackBar(
                        'Download request initiated. You will receive your data package via email within 48 hours.');
                  },
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  title: 'Delete My Account',
                  icon: Icons.delete_forever,
                  color: ColorConstants.error,
                  onTap: () {
                    _showDeleteConfirmationDialog();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds an action button for data management
  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: color == ColorConstants.error
                    ? color
                    : ColorConstants.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  /// Shows a confirmation dialog before deleting account
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This action cannot be undone. All your data, including trees planted and coins earned will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar(
                  'Account deletion process initiated. You will receive a confirmation email.');
            },
            child: const Text(
              'DELETE',
              style: TextStyle(
                color: ColorConstants.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a snackbar with the given message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
