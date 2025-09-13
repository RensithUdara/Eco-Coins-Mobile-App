import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:eco_coins_mobile_app/controllers/auth_controller.dart';
import 'package:eco_coins_mobile_app/controllers/tree_controller.dart';
import 'package:eco_coins_mobile_app/services/image_service.dart';
import 'package:eco_coins_mobile_app/utils/constants.dart';
import 'package:eco_coins_mobile_app/utils/helpers.dart';
import 'package:eco_coins_mobile_app/views/widgets/custom_button.dart';
import 'package:intl/intl.dart';

/// Screen for planting a new tree
class PlantTreeScreen extends StatefulWidget {
  const PlantTreeScreen({super.key});

  @override
  State<PlantTreeScreen> createState() => _PlantTreeScreenState();
}

class _PlantTreeScreenState extends State<PlantTreeScreen> {
  final TextEditingController _speciesController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  final ImageService _imageService = ImageService();
  File? _selectedImage;
  DateTime _selectedDate = DateTime.now();
  bool _termsAccepted = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  @override
  void dispose() {
    _speciesController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
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
      firstDate: DateTime.now().subtract(const Duration(days: 30)), // Allow backdating up to 30 days
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
  }

  /// Handle form submission
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedImage == null) {
      Helpers.showSnackBar(
        context,
        'Please upload a photo of your tree',
        isError: true,
      );
      return;
    }
    
    if (!_termsAccepted) {
      Helpers.showSnackBar(
        context,
        'Please accept the terms and conditions',
        isError: true,
      );
      return;
    }
    
    final authController = Provider.of<AuthController>(context, listen: false);
    final treeController = Provider.of<TreeController>(context, listen: false);
    
    if (authController.currentUser == null || authController.currentUser!.id == null) {
      Helpers.showSnackBar(
        context,
        'You must be logged in to plant a tree',
        isError: true,
      );
      return;
    }
    
    final bool success = await treeController.addTree(
      userId: authController.currentUser!.id!,
      species: _speciesController.text.trim(),
      description: _descriptionController.text.trim(),
      plantedDate: _selectedDate,
      photoFile: _selectedImage!,
    );
    
    if (success && mounted) {
      await authController.refreshUserData();
      Helpers.showSnackBar(context, 'Tree planted successfully!');
      
      // Navigate back to dashboard
      Navigator.pop(context);
    } else if (mounted) {
      Helpers.showSnackBar(
        context,
        treeController.errorMessage ?? 'Failed to plant tree',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.nature),
            const SizedBox(width: 8),
            const Text('Plant a Tree'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTreeInfoCard(),
                const SizedBox(height: 16),
                _buildPhotoUploadCard(),
                const SizedBox(height: 16),
                _buildTermsAndConditions(),
                const SizedBox(height: 16),
                _buildImportantGuidelines(),
                const SizedBox(height: 24),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build tree information card
  Widget _buildTreeInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tree Name/Species field
            Text(
              'Tree Name / Species',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ColorConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _speciesController,
              decoration: const InputDecoration(
                hintText: 'Mango tree',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the tree species';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Description field
            Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ColorConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'I planted today ...',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Date field
            Text(
              'Date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ColorConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'YYYY - MM - DD',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _selectDate,
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image.file(
            _selectedImage!,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () {
            setState(() {
              _selectedImage = null;
            });
          },
          icon: const Icon(Icons.delete),
          label: const Text('Remove Photo'),
          style: TextButton.styleFrom(
            foregroundColor: ColorConstants.error,
          ),
        ),
      ],
    );
  }

  /// Build image placeholder
  Widget _buildImagePlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          style: BorderStyle.dashed,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.camera_alt,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            'Take a photo of your\nplanted tree',
            textAlign: TextAlign.center,
            style: TextStyle(
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
        ElevatedButton(
          onPressed: _pickImageFromGallery,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: ColorConstants.textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          child: const Text('Gallery'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _pickImageFromCamera,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: ColorConstants.textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          child: const Text('Camera'),
        ),
      ],
    );
  }

  /// Build terms and conditions section
  Widget _buildTermsAndConditions() {
    return ElevatedButton(
      onPressed: () {
        _showTermsAndConditions();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorConstants.secondary,
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      child: const Text(
        'Terms & Conditions',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Build important guidelines section
  Widget _buildImportantGuidelines() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: ColorConstants.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Important Guidelines',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorConstants.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Flowers and small shrubs are not eligible.',
            style: TextStyle(
              fontSize: 14,
              color: ColorConstants.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Build submit button
  Widget _buildSubmitButton() {
    return Consumer<TreeController>(
      builder: (context, treeController, _) {
        final bool isLoading = treeController.state == TreeOperationState.loading;
        return CustomButton(
          text: 'Upload Tree Photo',
          onPressed: _handleSubmit,
          type: ButtonType.primary,
          isLoading: isLoading,
          icon: Icons.file_upload,
        );
      },
    );
  }

  /// Show terms and conditions dialog
  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms & Conditions'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '1. By uploading a photo, you certify that you have actually planted this tree.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Text(
                '2. You agree to maintain the tree for at least one year.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Text(
                '3. False claims may result in account suspension.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Text(
                '4. EcoCoins earned through tree planting are non-transferable.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _termsAccepted,
                    onChanged: (value) {
                      setState(() {
                        _termsAccepted = value ?? false;
                      });
                      Navigator.pop(context);
                    },
                    activeColor: ColorConstants.primary,
                  ),
                  const Expanded(
                    child: Text('I agree to the terms and conditions'),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}