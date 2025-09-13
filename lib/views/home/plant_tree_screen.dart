import 'dart:io';

import 'package:eco_coins_mobile_app/controllers/auth_controller.dart';
import 'package:eco_coins_mobile_app/controllers/tree_controller.dart';
import 'package:eco_coins_mobile_app/services/image_service.dart';
import 'package:eco_coins_mobile_app/utils/constants.dart';
import 'package:eco_coins_mobile_app/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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

    if (authController.currentUser == null ||
        authController.currentUser!.id == null) {
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
        elevation: 0,
        backgroundColor: ColorConstants.primary,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.nature, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Text(
              'Plant a Tree',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Green curved background at top
          Container(
            height: 50,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: ColorConstants.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          // Content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Impact Banner
                    _buildImpactBanner(),
                    const SizedBox(height: 20),

                    // Section Title
                    _buildSectionTitle('Tree Details', Icons.eco),
                    const SizedBox(height: 10),
                    _buildTreeInfoCard(),

                    const SizedBox(height: 20),
                    _buildSectionTitle('Tree Photo', Icons.photo_camera),
                    const SizedBox(height: 10),
                    _buildPhotoUploadCard(),

                    const SizedBox(height: 20),
                    _buildSectionTitle('Guidelines & Terms', Icons.gavel),
                    const SizedBox(height: 10),
                    _buildImportantGuidelines(),
                    const SizedBox(height: 16),
                    _buildTermsAndConditions(),

                    const SizedBox(height: 30),
                    _buildSubmitButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build section title
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: ColorConstants.primary,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ColorConstants.textPrimary,
          ),
        ),
      ],
    );
  }

  /// Build impact banner showing eco coins rewards
  Widget _buildImpactBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            ColorConstants.secondary,
            ColorConstants.secondaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                ),
              ],
            ),
            child: Image.asset(
              AssetPaths.coinIcon,
              height: 40,
              width: 40,
              errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.monetization_on,
                  size: 40,
                  color: Colors.amber),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plant & Earn',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Get ${CoinRewards.treePlanting} Eco Coins for planting a new tree!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build tree information card
  Widget _buildTreeInfoCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tree Name/Species field
            const Row(
              children: [
                Icon(Icons.local_florist,
                    color: ColorConstants.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Tree Name / Species',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _speciesController,
              decoration: InputDecoration(
                hintText: 'Mango tree, Oak, Pine...',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: ColorConstants.primary),
                ),
                prefixIcon:
                    const Icon(Icons.eco, color: ColorConstants.primary),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the tree species';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Description field
            const Row(
              children: [
                Icon(Icons.description,
                    color: ColorConstants.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Tell us about this tree and where you planted it...',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: ColorConstants.primary),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Date field
            const Row(
              children: [
                Icon(Icons.event, color: ColorConstants.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Planting Date',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.textPrimary,
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
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: ColorConstants.primary),
                ),
                suffixIcon: Container(
                  decoration: const BoxDecoration(
                    color: ColorConstants.primary,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.calendar_today, color: Colors.white),
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
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
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
        Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.file(
                  _selectedImage!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: ColorConstants.error,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _selectedImage = null;
                  });
                },
                icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                iconSize: 20,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: ColorConstants.success, size: 18),
            SizedBox(width: 8),
            Text(
              'Photo uploaded successfully',
              style: TextStyle(
                color: ColorConstants.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build image placeholder
  Widget _buildImagePlaceholder() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: ColorConstants.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Take a photo of your planted tree',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: ColorConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: const Text(
              'Photo should clearly show the tree you planted',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: ColorConstants.textSecondary,
              ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: ColorConstants.primary,
              elevation: 2,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: const BorderSide(color: ColorConstants.primary, width: 1),
              ),
            ),
            icon: const Icon(Icons.photo_library),
            label: const Text(
              'Gallery',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _pickImageFromCamera,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstants.primary,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            icon: const Icon(Icons.camera_alt),
            label: const Text(
              'Camera',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  /// Build terms and conditions section
  Widget _buildTermsAndConditions() {
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.secondaryLight.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorConstants.secondaryLight,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.verified_user,
                color: ColorConstants.secondary,
                size: 24,
              ),
              SizedBox(width: 10),
              Text(
                'Guidelines & Terms',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorConstants.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle,
                size: 18,
                color: ColorConstants.secondary,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Photos must clearly show a newly planted tree',
                  style: TextStyle(
                    color: ColorConstants.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle,
                size: 18,
                color: ColorConstants.secondary,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'You agree to maintain the tree for at least one year',
                  style: TextStyle(
                    color: ColorConstants.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle,
                size: 18,
                color: ColorConstants.secondary,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'False claims may result in account suspension',
                  style: TextStyle(
                    color: ColorConstants.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _showTermsAndConditions,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _termsAccepted,
                          onChanged: (value) {
                            setState(() {
                              _termsAccepted = value ?? false;
                            });
                          },
                          activeColor: ColorConstants.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'I agree to the terms and conditions',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _showTermsAndConditions,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Read more',
                      style: TextStyle(
                        color: ColorConstants.secondary,
                        fontWeight: FontWeight.bold,
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

  /// Build important guidelines section
  Widget _buildImportantGuidelines() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: ColorConstants.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: const Column(
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
          SizedBox(height: 8),
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
    final bool isFormReady = _termsAccepted && _selectedImage != null;

    return Column(
      children: [
        Container(
          height: 55,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: isFormReady
                ? const LinearGradient(
                    colors: [
                      ColorConstants.primary,
                      ColorConstants.primaryDark,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: isFormReady ? null : Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
            boxShadow: isFormReady
                ? [
                    BoxShadow(
                      color: ColorConstants.primary.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: MaterialButton(
            onPressed: isFormReady ? _handleSubmit : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            highlightColor: Colors.transparent,
            splashColor: Colors.white.withOpacity(0.2),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.eco,
                  color: Colors.white,
                ),
                SizedBox(width: 12),
                Text(
                  'Plant Your Tree',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isFormReady)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              _selectedImage == null
                  ? 'Please upload a photo of your tree'
                  : 'Please accept the terms and conditions',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }

  /// Show terms and conditions dialog
  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 5,
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: ColorConstants.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_user,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Terms & Conditions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTermItem(
                        icon: Icons.camera_alt,
                        title: 'Photo Certification',
                        description:
                            'By uploading a photo, you certify that you have actually planted this tree.',
                      ),
                      const SizedBox(height: 16),
                      _buildTermItem(
                        icon: Icons.calendar_today,
                        title: 'Maintenance Agreement',
                        description:
                            'You agree to maintain the tree for at least one year and provide maintenance updates when requested.',
                      ),
                      const SizedBox(height: 16),
                      _buildTermItem(
                        icon: Icons.warning_amber,
                        title: 'False Claims',
                        description:
                            'False claims may result in account suspension and forfeiture of all earned EcoCoins.',
                      ),
                      const SizedBox(height: 16),
                      _buildTermItem(
                        icon: Icons.token,
                        title: 'EcoCoins Policy',
                        description:
                            'EcoCoins earned through tree planting are non-transferable and can only be redeemed within the app.',
                      ),
                      const SizedBox(height: 16),
                      _buildTermItem(
                        icon: Icons.public,
                        title: 'Public Data',
                        description:
                            'Information about planted trees (excluding personal details) may be shared on public environmental databases.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _termsAccepted,
                      onChanged: (value) {
                        setState(() {
                          _termsAccepted = value ?? false;
                        });
                      },
                      activeColor: ColorConstants.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Flexible(
                    child: Text(
                      'I have read and agree to the terms and conditions',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _termsAccepted = true;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstants.secondary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text(
                        'Accept Terms',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build term item for the terms dialog
  Widget _buildTermItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ColorConstants.secondaryLight.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: ColorConstants.secondary,
            size: 20,
          ),
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
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
