import 'dart:io';

import 'package:eco_coins_mobile_app/controllers/auth_controller.dart';
import 'package:eco_coins_mobile_app/controllers/maintenance_controller.dart';
import 'package:eco_coins_mobile_app/controllers/tree_controller.dart';
import 'package:eco_coins_mobile_app/models/maintenance_model.dart';
import 'package:eco_coins_mobile_app/services/image_service.dart';
import 'package:eco_coins_mobile_app/utils/constants.dart';
import 'package:eco_coins_mobile_app/utils/helpers.dart';
import 'package:eco_coins_mobile_app/views/widgets/custom_button.dart';
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
    _loadUserTrees();
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
    final authController = Provider.of<AuthController>(context, listen: false);
    final treeController = Provider.of<TreeController>(context, listen: false);

    if (authController.currentUser == null ||
        authController.currentUser!.id == null) {
      Helpers.showSnackBar(
        context,
        'You must be logged in to maintain trees',
        isError: true,
      );
      Navigator.pop(context);
      return;
    }

    await treeController.fetchUserTrees(authController.currentUser!.id!);
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
                Helpers.showSnackBar(context, 'Maintenance history coming soon!');
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
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Tree',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ColorConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                hintText: 'Select a tree',
                border: OutlineInputBorder(),
              ),
              value: _selectedTree?.id,
              items: _userTrees.map((tree) {
                return DropdownMenuItem<int>(
                  value: tree.id,
                  child: Text(
                      '${tree.species} (Planted on: ${DateFormat('yyyy-MM-dd').format(tree.plantedDate)})'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedTree =
                        _userTrees.firstWhere((tree) => tree.id == value);
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
          ],
        ),
      ),
    );
  }

  /// Build maintenance type card
  Widget _buildMaintenanceTypeCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Maintenance Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ColorConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: MaintenanceActivity.values.map((activity) {
                final bool isSelected = _selectedActivity == activity;
                return ChoiceChip(
                  label: Text(_getActivityName(activity)),
                  selected: isSelected,
                  selectedColor: ColorConstants.primary,
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    color:
                        isSelected ? Colors.white : ColorConstants.textPrimary,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedActivity = activity;
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Build maintenance details card
  Widget _buildMaintenanceDetailsCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notes field with improved styling
            const Row(
              children: [
                Icon(Icons.edit_note, color: ColorConstants.primary),
                SizedBox(width: 8),
                Text(
                  'Maintenance Notes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.textPrimary,
                  ),
                ),
                Spacer(),
                Text(
                  'Required',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: ColorConstants.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'Add notes about your maintenance activity...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: ColorConstants.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some notes';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Date field with improved styling
            const Row(
              children: [
                Icon(Icons.calendar_today, color: ColorConstants.primary),
                SizedBox(width: 8),
                Text(
                  'Maintenance Date',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.textPrimary,
                  ),
                ),
                Spacer(),
                Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'YYYY - MM - DD',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: ColorConstants.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: ColorConstants.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.calendar_today,
                        color: ColorConstants.primary),
                    onPressed: _selectDate,
                  ),
                ),
              ),
              onTap: _selectDate,
            ),
          ],
        ),
      ),
    );
  }

  /// Build photo upload card
  Widget _buildPhotoUploadCard() {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
            color: ColorConstants.primaryLight.withOpacity(0.5), width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.photo_camera, color: ColorConstants.primary),
                const SizedBox(width: 8),
                const Text(
                  'Photo Documentation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  _selectedImage != null ? '1 Photo' : 'No Photos',
                  style: TextStyle(
                    fontSize: 12,
                    color: _selectedImage != null
                        ? ColorConstants.success
                        : ColorConstants.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _selectedImage != null
                ? _buildSelectedImage()
                : _buildImagePlaceholder(),
            const SizedBox(height: 16),
            _buildPhotoButtons(),
          ],
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
        // Remove photo button with improved positioning and styling
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.delete, color: ColorConstants.error),
              onPressed: () {
                setState(() {
                  _selectedImage = null;
                });
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
          bottom: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ColorConstants.success.withOpacity(0.9),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'Ready',
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ColorConstants.primaryDark, ColorConstants.primary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: ColorConstants.primary.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CustomButton(
        text: 'Record Maintenance',
        onPressed: _handleSubmit,
        type: ButtonType.primary,
        isLoading: false,
        icon: Icons.check_circle,
      ),
    );
  }
}
