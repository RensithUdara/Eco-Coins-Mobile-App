// Fixed _buildEnhancedImagePreview method
Widget _buildEnhancedImagePreview() {
  // Safety check - if selectedImage is null, return placeholder
  if (_selectedImage == null) {
    return _buildImagePlaceholder();
  }
  
  // Use a local file variable to avoid multiple null checks
  final imageFile = _selectedImage;
  
  return Stack(
    children: [
      // Image container with enhanced border and shadow
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
          clipBehavior: Clip.antiAlias,
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
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        title: const Text('Maintenance Photo',
                            style: TextStyle(color: Colors.white)),
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.white),
                            onPressed: () {
                              Navigator.pop(context);
                              Helpers.showSnackBar(context, 'Share feature coming soon!');
                            },
                          ),
                        ],
                      ),
                      Flexible(
                        child: InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: imageFile != null
                            ? Image.file(
                                imageFile,
                                fit: BoxFit.contain,
                              )
                            : const SizedBox(),
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
              child: imageFile != null
                ? Image.file(
                    imageFile,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 220,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                  ),
            ),
          ),
        ),
      ),
      
      // Remove photo button
      Positioned(
        top: 8,
        right: 8,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.delete_outline, color: ColorConstants.error),
            onPressed: () {
              setState(() {
                _selectedImage = null;
              });
            },
            tooltip: 'Remove photo',
            iconSize: 20,
          ),
        ),
      ),
    ],
  );
}