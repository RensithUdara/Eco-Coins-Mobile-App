import 'dart:io';

import 'package:eco_coins_mobile_app/controllers/auth_controller.dart';
import 'package:eco_coins_mobile_app/controllers/maintenance_controller.dart';
import 'package:eco_coins_mobile_app/controllers/tree_controller.dart';
import 'package:eco_coins_mobile_app/models/maintenance_model.dart';
import 'package:eco_coins_mobile_app/services/image_service.dart';
import 'package:eco_coins_mobile_app/utils/constants.dart';
import 'package:eco_coins_mobile_app/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Screen for maintaining trees
class MaintenanceScreen extends StatefulWidget {
  final dynamic tree;

  const MaintenanceScreen({this.tree, super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final TextEditingController _activityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final ImageService _imageService = ImageService();
  File? _selectedImage;
  DateTime _selectedDate = DateTime.now();
  dynamic _selectedTree;
  List<dynamic> _userTrees = [];
  MaintenanceActivity _selectedActivity = MaintenanceActivity.watering;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);

    // Defer _loadUserTrees to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserTrees();
    });
  }

  @override
  void dispose() {
    _activityController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  /// Load trees belonging to the current user
  Future<void> _loadUserTrees() async {
    if (!mounted) return;

    final authController = Provider.of<AuthController>(context, listen: false);
    final treeController = Provider.of<TreeController>(context, listen: false);

    if (authController.currentUser == null ||
        authController.currentUser!.id == null) {
      if (mounted) {
        Helpers.showSnackBar(
          context,
          'You must be logged in to maintain trees',
          isError: true,
        );
        Navigator.pop(context);
      }
      return;
    }

    await treeController.fetchUserTrees(authController.currentUser!.id!);

    if (mounted) {
      setState(() {
        _userTrees = treeController.userTrees;

        if (widget.tree != null) {
          _selectedTree = _userTrees.firstWhere(
            (tree) => tree?.id == widget.tree.id,
            orElse: () => _userTrees.isNotEmpty ? _userTrees.first : null,
          );
        } else if (_userTrees.isNotEmpty) {
          _selectedTree = _userTrees.first;
        }
      });
    }
  }

  /// Pick image from camera
  Future<void> _pickImageFromCamera() async {
    final File? image = await _imageService.pickImageFromCamera();
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  /// Pick image from gallery
  Future<void> _pickImageFromGallery() async {
    final File? image = await _imageService.pickImageFromGallery();
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  /// Select date
  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now()
          .subtract(const Duration(days: 30)), // Allow backdating up to 30 days
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
  }

  /// Get maintenance activity name
  String _getActivityName(MaintenanceActivity activity) {
    switch (activity) {
      case MaintenanceActivity.watering:
        return 'Watering';
      case MaintenanceActivity.pruning:
        return 'Pruning';
      case MaintenanceActivity.fertilizing:
        return 'Fertilizing';
      case MaintenanceActivity.pestControl:
        return 'Pest Control';
      case MaintenanceActivity.mulching:
        return 'Mulching';
      case MaintenanceActivity.other:
        return 'Other';
      default:
        return 'Unknown';
    }
  }

  /// Show help dialog
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: ColorConstants.primary),
            SizedBox(width: 8),
            Text('Maintenance Help'),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpItem(Icons.nature_people, 'Select Tree',
                  'Choose which of your planted trees you want to maintain.'),
              const Divider(),
              _buildHelpItem(Icons.category, 'Maintenance Type',
                  'Select what type of maintenance you performed on your tree.'),
              const Divider(),
              _buildHelpItem(Icons.edit_note, 'Notes',
                  'Describe what you did to maintain your tree in detail.'),
              const Divider(),
              _buildHelpItem(Icons.calendar_today, 'Date',
                  'Record when you performed the maintenance.'),
              const Divider(),
              _buildHelpItem(Icons.photo_camera, 'Photo',
                  'Take a photo as evidence of your tree maintenance activity.'),
              const SizedBox(height: 16),
              const Text(
                'Regular maintenance earns you Eco Coins!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ColorConstants.success,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  /// Build help item for dialog
  Widget _buildHelpItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorConstants.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: ColorConstants.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: ColorConstants.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Handle form submission
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedTree == null) {
      Helpers.showSnackBar(
        context,
        'Please select a tree to maintain',
        isError: true,
      );
      return;
    }

    if (_selectedImage == null) {
      Helpers.showSnackBar(
        context,
        'Please upload a photo of your maintenance activity',
        isError: true,
      );
      return;
    }

    final authController = Provider.of<AuthController>(context, listen: false);
    final maintenanceController =
        Provider.of<MaintenanceController>(context, listen: false);

    if (authController.currentUser == null ||
        authController.currentUser!.id == null) {
      Helpers.showSnackBar(
        context,
        'You must be logged in to record maintenance',
        isError: true,
      );
      return;
    }

    final bool success = await maintenanceController.addMaintenance(
      userId: authController.currentUser!.id!,
      treeId: _selectedTree!.id!,
      activity: _selectedActivity,
      notes: _notesController.text.trim(),
      date: _selectedDate,
      photoFile: _selectedImage!,
    );

    if (success && mounted) {
      await authController.refreshUserData();
      Helpers.showSnackBar(context, 'Maintenance recorded successfully!');

      // Navigate back
      Navigator.pop(context);
    } else if (mounted) {
      Helpers.showSnackBar(
        context,
        maintenanceController.errorMessage ?? 'Failed to record maintenance',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [ColorConstants.primaryDark, ColorConstants.primary],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: const Row(
          children: [
            Icon(Icons.eco, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Tree Maintenance',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Tooltip(
            message: 'Maintenance History',
            child: IconButton(
              icon: const Icon(Icons.history, color: Colors.white),
              onPressed: () {
                // Show maintenance history
                // You can implement this functionality later
                Helpers.showSnackBar(
                    context, 'Maintenance history coming soon!');
              },
            ),
          ),
          Tooltip(
            message: 'Help',
            child: IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.white),
              onPressed: () {
                // Show help information
                _showHelpDialog(context);
              },
            ),
          ),
        ],
      ),
      body: _userTrees.isEmpty
          ? _buildNoTreesAvailable()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTreeSelectionCard(),
                      const SizedBox(height: 16),
                      _buildMaintenanceTypeCard(),
                      const SizedBox(height: 16),
                      _buildMaintenanceDetailsCard(),
                      const SizedBox(height: 16),
                      _buildPhotoUploadCard(),
                      const SizedBox(height: 24),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  /// Build message when no trees are available
  Widget _buildNoTreesAvailable() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.nature_outlined,
            size: 72,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No trees available for maintenance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Plant a tree first to start maintaining',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/plant-tree');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstants.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            child: const Text('Plant a Tree'),
          ),
        ],
      ),
    );
  }

  /// Build tree selection card
  Widget _buildTreeSelectionCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(
              color: ColorConstants.primaryLight.withOpacity(0.2), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorConstants.primaryLight.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.park_rounded,
                      color: ColorConstants.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Select Your Tree',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColorConstants.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ColorConstants.primaryLight.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_userTrees.length} Trees',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: ColorConstants.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Which tree are you maintaining today?',
                style: TextStyle(
                  fontSize: 14,
                  color: ColorConstants.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  hintText: 'Select a tree',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(
                    Icons.nature,
                    color: ColorConstants.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: ColorConstants.primary, width: 2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                value: _selectedTree?.id,
                icon: const Icon(Icons.arrow_drop_down_circle,
                    color: ColorConstants.primary),
                items: _userTrees.map((tree) {
                  return DropdownMenuItem<int>(
                    value: tree.id,
                    child: Row(
                      children: [
                        Icon(
                          _getTreeIcon(tree.species),
                          color: ColorConstants.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                tree.species,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                tree.plantedDate != null
                                    ? 'Planted: ${DateFormat('MMM d, yyyy').format(tree.plantedDate)}'
                                    : 'Planted: Unknown',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null && mounted) {
                    // Use Future.microtask to avoid setState during build
                    Future.microtask(() {
                      if (mounted) {
                        setState(() {
                          _selectedTree = _userTrees.firstWhere(
                            (tree) => tree?.id == value,
                            orElse: () => null,
                          );
                        });
                      }
                    });
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a tree';
                  }
                  return null;
                },
              ),
              if (_selectedTree != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: _buildSelectedTreeInfo(_selectedTree!),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get tree icon based on species
  IconData _getTreeIcon(String species) {
    if (species.isEmpty) {
      return Icons.forest; // Default icon if species is empty
    }

    final speciesLower = species.toLowerCase();
    if (speciesLower.contains('oak')) {
      return Icons.park;
    } else if (speciesLower.contains('pine') || speciesLower.contains('fir')) {
      return Icons.nature;
    } else if (speciesLower.contains('palm')) {
      return Icons.spa;
    } else if (speciesLower.contains('flower') ||
        speciesLower.contains('rose')) {
      return Icons.local_florist;
    } else {
      return Icons.forest;
    }
  }

  /// Build selected tree info card
  Widget _buildSelectedTreeInfo(dynamic tree) {
    // If tree is null, return an empty container
    if (tree == null) {
      return Container();
    }

    // Safe access to properties with null checks
    final String species = tree.species ?? 'Unknown Species';
    final DateTime? plantedDate = tree.plantedDate;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorConstants.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorConstants.primaryLight.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: ColorConstants.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTreeIcon(species),
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  species,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 12, color: ColorConstants.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      plantedDate != null
                          ? 'Planted on: ${DateFormat('MMM d, yyyy').format(plantedDate)}'
                          : 'Planted on: Unknown',
                      style: const TextStyle(
                        fontSize: 12,
                        color: ColorConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 12, color: ColorConstants.textSecondary),
                    SizedBox(width: 4),
                    Text(
                      'Location: Not specified',
                      style: TextStyle(
                        fontSize: 12,
                        color: ColorConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Get icon for maintenance activity
  IconData _getActivityIcon(MaintenanceActivity activity) {
    switch (activity) {
      case MaintenanceActivity.watering:
        return Icons.water_drop;
      case MaintenanceActivity.pruning:
        return Icons.content_cut;
      case MaintenanceActivity.fertilizing:
        return Icons.compost;
      case MaintenanceActivity.pestControl:
        return Icons.bug_report;
      case MaintenanceActivity.mulching:
        return Icons.layers;
      case MaintenanceActivity.other:
        return Icons.more_horiz;
      default:
        return Icons.help_outline;
    }
  }

  /// Build maintenance type card
  Widget _buildMaintenanceTypeCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(
              color: ColorConstants.primaryLight.withOpacity(0.2), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorConstants.primaryLight.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.eco_outlined,
                      color: ColorConstants.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Maintenance Type',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColorConstants.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'What type of maintenance did you perform?',
                style: TextStyle(
                  fontSize: 14,
                  color: ColorConstants.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: MaintenanceActivity.values.map((activity) {
                  final bool isSelected = _selectedActivity == activity;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedActivity = activity;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? ColorConstants.primary.withOpacity(0.15)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? ColorConstants.primary
                              : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? ColorConstants.primary
                                  : ColorConstants.primaryLight
                                      .withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getActivityIcon(activity),
                              color: isSelected
                                  ? Colors.white
                                  : ColorConstants.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getActivityName(activity),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? ColorConstants.primary
                                  : ColorConstants.textPrimary,
                              fontSize: 12,
                            ),
                          ),
                          if (isSelected)
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Icon(
                                Icons.check_circle,
                                color: ColorConstants.primary,
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              if (_selectedActivity == MaintenanceActivity.other)
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Specify other maintenance activity...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: ColorConstants.primary, width: 2),
                    ),
                    prefixIcon:
                        const Icon(Icons.edit, color: ColorConstants.primary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build maintenance details card
  Widget _buildMaintenanceDetailsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(
              color: ColorConstants.primaryLight.withOpacity(0.2), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorConstants.primaryLight.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.assignment_rounded,
                      color: ColorConstants.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Maintenance Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColorConstants.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 16),

              // Notes field with improved styling
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: ColorConstants.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.edit_note,
                              color: ColorConstants.primary, size: 18),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Maintenance Notes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ColorConstants.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: ColorConstants.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: ColorConstants.info.withOpacity(0.3)),
                          ),
                          child: const Text(
                            'Required',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: ColorConstants.info,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        hintText:
                            'Add notes about your maintenance activity...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: ColorConstants.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 8.0),
                          child: Icon(
                            Icons.description,
                            color: ColorConstants.primary,
                          ),
                        ),
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some notes';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Provide detailed information about what you did for your tree',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: ColorConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Date field with improved styling
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: ColorConstants.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.calendar_today,
                              color: ColorConstants.primary, size: 18),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Maintenance Date',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ColorConstants.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: ColorConstants.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: ColorConstants.success.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.today,
                                size: 12,
                                color: ColorConstants.success,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('dd MMM').format(DateTime.now()),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: ColorConstants.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _selectDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color:
                                  ColorConstants.primaryLight.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              color: ColorConstants.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('EEEE, MMMM d, yyyy')
                                  .format(_selectedDate),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: ColorConstants.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: ColorConstants.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.edit_calendar,
                                color: ColorConstants.primary,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Hidden text field for validation
                    Opacity(
                      opacity: 0,
                      child: TextFormField(
                        controller: _dateController,
                        enabled: false,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build photo upload card
  Widget _buildPhotoUploadCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(
              color: _selectedImage != null
                  ? ColorConstants.success.withOpacity(0.5)
                  : ColorConstants.primaryLight.withOpacity(0.3),
              width: _selectedImage != null ? 2.0 : 1.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _selectedImage != null
                          ? ColorConstants.success.withOpacity(0.1)
                          : ColorConstants.primaryLight.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _selectedImage != null
                          ? Icons.check_circle
                          : Icons.photo_camera,
                      color: _selectedImage != null
                          ? ColorConstants.success
                          : ColorConstants.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Photo Documentation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColorConstants.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _selectedImage != null
                          ? ColorConstants.success.withOpacity(0.1)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: _selectedImage != null
                            ? ColorConstants.success.withOpacity(0.5)
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _selectedImage != null
                              ? Icons.check
                              : Icons.info_outline,
                          size: 14,
                          color: _selectedImage != null
                              ? ColorConstants.success
                              : ColorConstants.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _selectedImage != null ? 'Photo Ready' : 'Required',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _selectedImage != null
                                ? ColorConstants.success
                                : ColorConstants.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: _selectedImage != null
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: _buildEnhancedImagePreview(),
                secondChild: _buildImagePlaceholder(),
              ),
              const SizedBox(height: 16),
              _buildPhotoButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build selected image preview
  Widget _buildSelectedImage() {
    return Stack(
      children: [
        // Image container with enhanced border and shadow
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Hero(
            tag: 'maintenance_photo',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Show full-screen image preview dialog
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      insetPadding: const EdgeInsets.all(16),
                      backgroundColor: Colors.transparent,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppBar(
                            backgroundColor: Colors.black.withOpacity(0.7),
                            elevation: 0,
                            leading: IconButton(
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                            title: const Text('Maintenance Photo',
                                style: TextStyle(color: Colors.white)),
                            actions: [
                              IconButton(
                                icon: const Icon(Icons.share,
                                    color: Colors.white),
                                onPressed: () {
                                  Navigator.pop(context);
                                  Helpers.showSnackBar(
                                      context, 'Share feature coming soon!');
                                },
                              ),
                            ],
                          ),
                          Flexible(
                            child: InteractiveViewer(
                              minScale: 0.5,
                              maxScale: 4.0,
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.file(
                    _selectedImage!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Remove photo button with improved positioning and styling
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  spreadRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: IconButton(
              icon:
                  const Icon(Icons.delete_outline, color: ColorConstants.error),
              onPressed: () {
                // Add a confirmation dialog for better UX
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: ColorConstants.warning),
                        SizedBox(width: 8),
                        Text('Remove Photo?'),
                      ],
                    ),
                    content: const Text(
                        'Are you sure you want to remove this photo?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedImage = null;
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorConstants.error,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Remove'),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'Remove Photo',
              iconSize: 24,
              constraints: const BoxConstraints(
                minHeight: 40,
                minWidth: 40,
              ),
            ),
          ),
        ),
        // Success indicator
        Positioned(
          bottom: 16,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ColorConstants.success.withOpacity(0.9),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  spreadRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'Photo Verified',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        // View full screen indicator
        Positioned(
          bottom: 16,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fullscreen, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'Tap to View',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build enhanced image preview
  Widget _buildEnhancedImagePreview() {
    return Stack(
      children: [
        // Image container with enhanced border and shadow
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Hero(
            tag: 'maintenance_photo',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Show full-screen image preview dialog
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      insetPadding: const EdgeInsets.all(16),
                      backgroundColor: Colors.transparent,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppBar(
                            backgroundColor: Colors.black.withOpacity(0.7),
                            elevation: 0,
                            leading: IconButton(
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                            title: const Text('Maintenance Photo',
                                style: TextStyle(color: Colors.white)),
                            actions: [
                              IconButton(
                                icon: const Icon(Icons.share,
                                    color: Colors.white),
                                onPressed: () {
                                  Navigator.pop(context);
                                  Helpers.showSnackBar(
                                      context, 'Share feature coming soon!');
                                },
                              ),
                            ],
                          ),
                          Flexible(
                            child: InteractiveViewer(
                              minScale: 0.5,
                              maxScale: 4.0,
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.file(
                    _selectedImage!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Remove photo button with improved positioning and styling
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  spreadRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: IconButton(
              icon:
                  const Icon(Icons.delete_outline, color: ColorConstants.error),
              onPressed: () {
                // Add a confirmation dialog for better UX
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: ColorConstants.warning),
                        SizedBox(width: 8),
                        Text('Remove Photo?'),
                      ],
                    ),
                    content: const Text(
                        'Are you sure you want to remove this photo?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedImage = null;
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorConstants.error,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Remove'),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'Remove Photo',
              iconSize: 24,
              constraints: const BoxConstraints(
                minHeight: 40,
                minWidth: 40,
              ),
            ),
          ),
        ),
        // Success indicator
        Positioned(
          bottom: 16,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ColorConstants.success.withOpacity(0.9),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  spreadRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'Photo Verified',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        // View full screen indicator
        Positioned(
          bottom: 16,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fullscreen, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'Tap to View',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build image placeholder
  Widget _buildImagePlaceholder() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(
          color: Colors.grey[300]!,
          style: BorderStyle.solid,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorConstants.primaryLight.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt,
              size: 48,
              color: ColorConstants.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Take a photo of your',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorConstants.textPrimary,
            ),
          ),
          const Text(
            'maintenance activity',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This helps verify your tree care',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: ColorConstants.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Build photo selection buttons
  Widget _buildPhotoButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _pickImageFromGallery,
            icon: const Icon(Icons.photo_library, size: 20),
            label: const Text('Gallery'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstants.primaryLight.withOpacity(0.2),
              foregroundColor: ColorConstants.primaryDark,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: BorderSide(
                    color: ColorConstants.primaryLight.withOpacity(0.5)),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _pickImageFromCamera,
            icon: const Icon(Icons.camera_alt, size: 20),
            label: const Text('Camera'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstants.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build submit button
  Widget _buildSubmitButton() {
    // Check if form is ready for submission (tree selected and image uploaded)
    bool isFormReady = _selectedTree != null && _selectedImage != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFormReady
              ? [ColorConstants.primaryDark, ColorConstants.primary]
              : [Colors.grey[400]!, Colors.grey[500]!],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: isFormReady
                ? ColorConstants.primary.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            blurRadius: isFormReady ? 10 : 5,
            spreadRadius: isFormReady ? 2 : 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.0),
        child: InkWell(
          onTap: isFormReady
              ? _handleSubmit
              : () {
                  // Show what's missing in the form
                  if (_selectedTree == null && _selectedImage == null) {
                    Helpers.showSnackBar(
                        context, 'Please select a tree and upload a photo',
                        isError: true);
                  } else if (_selectedTree == null) {
                    Helpers.showSnackBar(
                        context, 'Please select a tree to maintain',
                        isError: true);
                  } else if (_selectedImage == null) {
                    Helpers.showSnackBar(context,
                        'Please upload a photo of your maintenance activity',
                        isError: true);
                  }
                },
          borderRadius: BorderRadius.circular(20.0),
          splashColor: isFormReady
              ? ColorConstants.primaryLight.withOpacity(0.3)
              : Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isFormReady ? Icons.check_circle : Icons.info_outline,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  isFormReady
                      ? 'Record Maintenance'
                      : 'Complete Required Fields',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isFormReady) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.eco,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '+${CoinRewards.oneMonthUpdate} coins',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
