import 'package:eco_coins_mobile_app/controllers/auth_controller.dart';
import 'package:eco_coins_mobile_app/models/user_model.dart';
import 'package:eco_coins_mobile_app/utils/constants.dart';
import 'package:flutter/material.dart';
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
    _nameController = TextEditingController(text: authController.currentUser?.name ?? '');
    _emailController = TextEditingController(text: authController.currentUser?.email ?? '');
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
        final authController = Provider.of<AuthController>(context, listen: false);
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

      final authController = Provider.of<AuthController>(context, listen: false);
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
              content: Text(authController.errorMessage ?? 'Failed to update profile'),
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
    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          _isEditing
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _toggleEditMode,
                  tooltip: 'Cancel',
                )
              : IconButton(
                  icon: const Icon(Icons.edit),
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

          return _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Profile Avatar
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: ColorConstants.primaryLight,
                        child: Text(
                          _getInitials(user.name),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // User information or edit form
                      _isEditing ? _buildEditForm() : _buildProfileInfo(user),
                      
                      const SizedBox(height: 40),
                      
                      // Account actions
                      _buildAccountActions(),
                    ],
                  ),
                );
        },
      ),
    );
  }

  /// Build the profile information display
  Widget _buildProfileInfo(User user) {
    return Column(
      children: [
        Text(
          user.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          user.email,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: ColorConstants.textSecondary,
              ),
        ),
        const SizedBox(height: 24),
        // Stats
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          decoration: BoxDecoration(
            color: ColorConstants.cardBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildStatRow('Eco Coins Balance', '${user.coinsBalance}', Icons.monetization_on, ColorConstants.secondary),
              const Divider(height: 30),
              _buildStatRow('Member Since', _formatDate(user.createdAt), Icons.calendar_today, ColorConstants.primary),
            ],
          ),
        ),
      ],
    );
  }

  /// Build a row for user statistics
  Widget _buildStatRow(String label, String value, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 16),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: ColorConstants.textSecondary,
                ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  /// Build the edit form
  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name field
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          
          // Save button
          ElevatedButton.icon(
            onPressed: _saveProfile,
            icon: const Icon(Icons.save),
            label: const Text('Save Changes'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstants.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
            ),
          ),
        ],
      ),
    );
  }

  /// Build account actions section
  Widget _buildAccountActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(),
        const SizedBox(height: 16),
        // Sign out button
        OutlinedButton.icon(
          onPressed: _signOut,
          icon: const Icon(Icons.logout, color: ColorConstants.error),
          label: const Text('Sign Out'),
          style: OutlinedButton.styleFrom(
            foregroundColor: ColorConstants.error,
            side: const BorderSide(color: ColorConstants.error),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
          ),
        ),
      ],
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
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}