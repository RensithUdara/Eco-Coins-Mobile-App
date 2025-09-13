import 'package:eco_coins_mobile_app/utils/constants.dart';
import 'package:flutter/material.dart';

/// Button types
enum ButtonType {
  primary,
  secondary,
  warning,
  danger,
}

/// Custom button widget
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final bool isFullWidth;
  final bool isLoading;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.isFullWidth = true,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getButtonColor(),
          foregroundColor: _getTextColor(),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          elevation: 3,
        ),
        child: isLoading ? _buildLoadingIndicator() : _buildButtonContent(),
      ),
    );
  }

  /// Get the button color based on the type
  Color _getButtonColor() {
    switch (type) {
      case ButtonType.primary:
        return ColorConstants.primary;
      case ButtonType.secondary:
        return ColorConstants.secondary;
      case ButtonType.warning:
        return ColorConstants.warning;
      case ButtonType.danger:
        return ColorConstants.error;
    }
  }

  /// Get the text color based on the type
  Color _getTextColor() {
    switch (type) {
      case ButtonType.primary:
        return Colors.white;
      case ButtonType.secondary:
        return Colors.black;
      case ButtonType.warning:
        return Colors.black;
      case ButtonType.danger:
        return Colors.white;
    }
  }

  /// Build loading indicator
  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
      ),
    );
  }

  /// Build button content
  Widget _buildButtonContent() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
