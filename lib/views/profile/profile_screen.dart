import 'package:eco_coins_mobile_app/controllers/auth_controller.dart';
import 'package:eco_coins_mobile_app/models/user_model.dart';
import 'package:eco_coins_mobile_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

/// Profile screen for user to view and update their profile
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authController = Provider.of<AuthController>(context, listen: false);
    _nameController =
        TextEditingController(text: authController.currentUser?.name ?? '');
    _emailController =
        TextEditingController(text: authController.currentUser?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Toggle between edit and view modes
  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset fields if canceling edit
        final authController =
            Provider.of<AuthController>(context, listen: false);
        _nameController.text = authController.currentUser?.name ?? '';
        _emailController.text = authController.currentUser?.email ?? '';
      }
    });
  }

  /// Save profile changes
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authController =
          Provider.of<AuthController>(context, listen: false);
      final success = await authController.updateUserProfile(
        name: _nameController.text,
        email: _emailController.text,
      );

      setState(() {
        _isLoading = false;
        if (success) {
          _isEditing = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: ColorConstants.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  authController.errorMessage ?? 'Failed to update profile'),
              backgroundColor: ColorConstants.error,
            ),
          );
        }
      });
    }
  }

  /// Sign out the user
  Future<void> _signOut() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    await authController.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar to transparent for immersive design
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: ColorConstants.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profile',
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
          _isEditing
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: _toggleEditMode,
                  tooltip: 'Cancel',
                )
              : IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: _toggleEditMode,
                  tooltip: 'Edit Profile',
                ),
        ],
      ),
      body: Consumer<AuthController>(
        builder: (context, authController, _) {
          final user = authController.currentUser;
          if (user == null) {
            return const Center(child: Text('User not found'));
          }

          return Stack(
            children: [
              // Header gradient background
              Container(
                height: 300, // Increased height to match screenshot
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
                      top: -30,
                      right: -30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 30,
                      left: -20,
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

              // Content
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Profile Avatar with decoration
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Hero(
                                tag: 'profile-avatar',
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: const Color(
                                      0xFFFFD700), // Golden yellow to match screenshot
                                  child: Text(
                                    _getInitials(user.name),
                                    style: const TextStyle(
                                      fontSize:
                                          50, // Larger font size to match screenshot
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing:
                                          1.5, // Add letter spacing for better readability
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // User information or edit form
                          _isEditing
                              ? _buildEditForm()
                              : _buildProfileInfo(user),

                          const SizedBox(height: 40),

                          // Account actions
                          _buildAccountActions(),
                        ],
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }

  /// Build the profile information display
  Widget _buildProfileInfo(User user) {
    return Column(
      children: [
        // The name and email are displayed directly without a container background
        // This matches the screenshot better
          child: Column(
            children: [
              // User name with animated fade-in
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: child,
                  );
                },
                child: Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3,
                        color: Color.fromRGBO(0, 0, 0, 0.5),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),

              // User email with animated fade-in
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: child,
                  );
                },
                child: Text(
                  user.email,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    shadows: const [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 2,
                        color: Color.fromRGBO(0, 0, 0, 0.5),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),

        // Stats cards
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
                child: Text(
                  'Account Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),

              // Coins card
              _buildStatCard(
                title: 'Eco Coins Balance',
                value: '${user.coinsBalance}',
                icon: Icons.monetization_on,
                iconBackground: ColorConstants.secondary,
                description: 'Your current eco coins',
              ),
              const SizedBox(height: 16),

              // Member since card
              _buildStatCard(
                title: 'Member Since',
                value: _formatDate(user.createdAt),
                icon: Icons.calendar_today,
                iconBackground: ColorConstants.primary,
                description: 'Account creation date',
              ),

              const SizedBox(height: 16),

              // Activity card - this could be connected to real data in the future
              _buildStatCard(
                title: 'Environmental Impact',
                value: 'Positive',
                icon: Icons.eco,
                iconBackground: ColorConstants.primaryLight,
                description: 'Your contribution to the environment',
                gradient: const LinearGradient(
                  colors: [ColorConstants.primaryLight, ColorConstants.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build a stat card with enhanced visual design
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconBackground,
    required String description,
    LinearGradient? gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: gradient == null ? ColorConstants.cardBackground : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon with background
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: gradient == null
                  ? iconBackground.withOpacity(0.1)
                  : Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: gradient == null ? iconBackground : Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: gradient == null
                        ? ColorConstants.textSecondary
                        : Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: gradient == null
                        ? ColorConstants.textPrimary
                        : Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: gradient == null
                        ? ColorConstants.textLight
                        : Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build the edit form
  Widget _buildEditForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Edit Your Profile',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.primary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Name field
            _buildAnimatedFormField(
              label: 'Full Name',
              controller: _nameController,
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
              keyboardType: TextInputType.name,
              hintText: 'Enter your full name',
            ),
            const SizedBox(height: 20),

            // Email field
            _buildAnimatedFormField(
              label: 'Email Address',
              controller: _emailController,
              icon: Icons.email,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
              keyboardType: TextInputType.emailAddress,
              hintText: 'Enter your email address',
            ),
            const SizedBox(height: 30),

            // Save button
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  colors: [
                    ColorConstants.primary,
                    ColorConstants.primaryDark,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorConstants.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
              ),
            ),

            // Cancel link
            TextButton(
              onPressed: _toggleEditMode,
              style: TextButton.styleFrom(
                foregroundColor: ColorConstants.textSecondary,
              ),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build animated form field with custom styling
  Widget _buildAnimatedFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          prefixIcon: Icon(icon, color: ColorConstants.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 16.0,
          ),
          labelStyle: const TextStyle(
            color: ColorConstants.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          errorStyle: const TextStyle(
            color: ColorConstants.error,
            fontSize: 12,
          ),
        ),
        validator: validator,
      ),
    );
  }

  /// Build account actions section
  Widget _buildAccountActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),

          // Actions title
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
            child: Text(
              'Account Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          // Action buttons
          _buildActionButton(
            title: 'Privacy Settings',
            icon: Icons.security,
            iconColor: ColorConstants.info,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Privacy settings will be available in a future update'),
                  backgroundColor: ColorConstants.info,
                ),
              );
            },
          ),

          _buildActionButton(
            title: 'Notification Preferences',
            icon: Icons.notifications,
            iconColor: ColorConstants.warning,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Notification settings will be available in a future update'),
                  backgroundColor: ColorConstants.warning,
                ),
              );
            },
          ),

          _buildActionButton(
            title: 'Help & Support',
            icon: Icons.help_outline,
            iconColor: ColorConstants.primary,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Support center will be available in a future update'),
                  backgroundColor: ColorConstants.primary,
                ),
              );
            },
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Sign out button with animation
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                        color: ColorConstants.error.withOpacity(0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: ColorConstants.error.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _signOut,
                      borderRadius: BorderRadius.circular(28),
                      splashColor: ColorConstants.error.withOpacity(0.1),
                      highlightColor: ColorConstants.error.withOpacity(0.05),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout,
                              color: ColorConstants.error,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Sign Out',
                              style: TextStyle(
                                color: ColorConstants.error,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Build action button with consistent styling
  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right,
                  color: ColorConstants.textLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Get user initials from name
  String _getInitials(String name) {
    List<String> nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return nameParts[0][0].toUpperCase() + nameParts[1][0].toUpperCase();
    } else {
      return name.isNotEmpty ? name[0].toUpperCase() : '?';
    }
  }

  /// Format date to readable string
  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
