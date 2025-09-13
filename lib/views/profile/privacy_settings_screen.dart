import 'package:eco_coins_mobile_app/utils/constants.dart';
import 'package:flutter/material.dart';

/// Custom painter for bubble pattern in header background
class BubblePatternPainter extends CustomPainter {
  final double animationValue;

  BubblePatternPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final bubbleSizes = [10.0, 15.0, 8.0, 12.0, 7.0];
    final positions = [
      Offset(size.width * 0.1, size.height * 0.2),
      Offset(size.width * 0.3, size.height * 0.7),
      Offset(size.width * 0.5, size.height * 0.3),
      Offset(size.width * 0.7, size.height * 0.6),
      Offset(size.width * 0.9, size.height * 0.4),
    ];

    for (int i = 0; i < bubbleSizes.length; i++) {
      // Calculate dynamic radius with animation
      final radius = bubbleSizes[i] *
          (0.8 + 0.2 * (i % 2 == 0 ? animationValue : 1 - animationValue));

      // Calculate position with slight movement
      final offsetX = positions[i].dx + (i % 2 == 0 ? 5 : -5) * animationValue;
      final offsetY = positions[i].dy + (i % 3 == 0 ? 3 : -3) * animationValue;

      canvas.drawCircle(Offset(offsetX, offsetY), radius, paint);
    }
  }

  @override
  bool shouldRepaint(BubblePatternPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

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

  /// Builds the header section with privacy information and parallax effect
  Widget _buildHeader() {
    return SizedBox(
      height: 180, // Increased height to accommodate content
      width: double.infinity,
      child: Stack(
        children: [
          // Animated background with parallax effect
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 1),
              builder: (context, value, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: const [
                        ColorConstants.primaryDark,
                        ColorConstants.primary,
                        ColorConstants.primaryLight,
                      ],
                      stops: [0.0, 0.5 + (0.2 * value), 1.0],
                    ),
                  ),
                  child: Opacity(
                    opacity: 0.15,
                    child: CustomPaint(
                      painter: BubblePatternPainter(
                        animationValue: value,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Foreground content
          Padding(
            padding: const EdgeInsets.all(16.0), // Reduced padding
            child: SingleChildScrollView(
              // Added SingleChildScrollView to handle potential overflow
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Use minimum space
                children: [
                  // Animated icon
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8), // Reduced padding
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: Colors.white,
                        size: 24, // Slightly smaller icon
                      ),
                    ),
                  ),

                  const SizedBox(height: 8), // Reduced spacing

                  // Title with fade-in effect
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: const Text(
                      'Your Privacy Matters',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6), // Reduced spacing

                  // Subtitle with delay and fade-in
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      'Control how your information is used within the Eco Coins app.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        letterSpacing: 0.2,
                      ),
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

  /// Builds a modern switch tile for toggling settings with animation
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    // Add consistent animation with same color scheme
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.95, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: value
                  ? ColorConstants.primary.withOpacity(0.15)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: value
                ? ColorConstants.primary.withOpacity(0.5)
                : Colors.grey.withOpacity(0.2),
            width: value ? 1.5 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onChanged(!value),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Leading Icon with animation
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: value
                            ? ColorConstants.primary.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        value
                            ? Icons.check_circle_outline
                            : Icons.circle_outlined,
                        color: value ? ColorConstants.primary : Colors.grey,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Title and subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: value
                                  ? ColorConstants.primaryDark
                                  : ColorConstants.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Custom animated switch
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 50,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: value
                            ? ColorConstants.primary
                            : Colors.grey.withOpacity(0.3),
                      ),
                      child: Stack(
                        children: [
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            left: value ? 22 : 2,
                            top: 2,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    spreadRadius: 0.5,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
        
        // Privacy completion progress bar
        const SizedBox(height: 20),
        _buildProgressBar(),
        
        // Next section navigation box
        const SizedBox(height: 24),
        _buildNextSectionBox(),
      ],
    );
  }
  
  /// Builds an animated progress bar showing privacy settings completion
  Widget _buildProgressBar() {
    // Calculate progress based on enabled settings
    final int totalSettings = 5; // Total number of toggleable settings
    final int enabledSettings = [
      _locationServices,
      _dataCollection,
      _profileVisibility,
      _achievementsPublic,
      _marketingEmails
    ].where((setting) => setting).length;
    
    final double progressPercent = enabledSettings / totalSettings;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Privacy Profile Completion',
              style: TextStyle(
                color: ColorConstants.primaryDark,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Text(
              '${(progressPercent * 100).toInt()}%',
              style: TextStyle(
                color: ColorConstants.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: progressPercent),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Container(
              width: double.infinity,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: const [
                            ColorConstants.primary,
                            ColorConstants.primaryLight,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
  
  /// Builds an animated next section navigation box
  Widget _buildNextSectionBox() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.9, end: 1.0),
      duration: const Duration(milliseconds: 400),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              ColorConstants.primary,
              ColorConstants.primaryDark,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: ColorConstants.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
              // You can add navigation to the next section if needed
              _showSnackBar('Settings saved successfully!');
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Save & Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Return to profile settings',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
