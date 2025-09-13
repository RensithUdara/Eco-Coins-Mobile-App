import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eco_coins_mobile_app/controllers/auth_controller.dart';
import 'package:eco_coins_mobile_app/utils/constants.dart';
import 'package:eco_coins_mobile_app/utils/helpers.dart';
import 'package:eco_coins_mobile_app/views/widgets/custom_button.dart';

/// Sign up screen for user registration
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Handle sign up button press
  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      final authController = Provider.of<AuthController>(context, listen: false);
      final success = await authController.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, AppConstants.dashboardRoute);
      } else if (mounted) {
        Helpers.showSnackBar(
          context,
          authController.errorMessage ?? 'Registration failed',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                _buildLogo(),
                const SizedBox(height: 24),
                _buildCreateAccountText(),
                const SizedBox(height: 32),
                _buildSignUpForm(),
                const SizedBox(height: 24),
                _buildSignUpButton(),
                const SizedBox(height: 24),
                _buildLoginLink(),
                const SizedBox(height: 40),
                _buildDecorativeElements(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build app logo
  Widget _buildLogo() {
    return Column(
      children: [
        const Icon(
          Icons.eco,
          size: 80,
          color: ColorConstants.primary,
        ),
        const SizedBox(height: 16),
        Text(
          AppConstants.appName,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: ColorConstants.primary,
          ),
        ),
      ],
    );
  }

  /// Build create account text
  Widget _buildCreateAccountText() {
    return const Text(
      'Create a new account',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: ColorConstants.textPrimary,
      ),
    );
  }

  /// Build sign up form
  Widget _buildSignUpForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name label
          Text(
            'Full Name',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          // Name input field
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Your Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Email label
          Text(
            'E-mail',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          // Email input field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'your.email@example.com',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!Helpers.isValidEmail(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Password label
          Text(
            'Password',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          // Password input field
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              hintText: '****************',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Confirm Password label
          Text(
            'Confirm Password',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          // Confirm Password input field
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            decoration: InputDecoration(
              hintText: '****************',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  /// Build sign up button
  Widget _buildSignUpButton() {
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        final bool isLoading = authController.state == AuthState.loading;
        return CustomButton(
          text: 'SIGN UP',
          onPressed: _handleSignUp,
          isLoading: isLoading,
        );
      },
    );
  }

  /// Build login link
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account?',
          style: TextStyle(
            color: ColorConstants.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
          },
          child: Text(
            'Sign In',
            style: TextStyle(
              color: ColorConstants.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Build decorative elements (coin icons)
  Widget _buildDecorativeElements() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCoinIcon(16),
        const SizedBox(width: 32),
        _buildCoinIcon(24),
        const SizedBox(width: 32),
        _buildCoinIcon(16),
      ],
    );
  }

  /// Build a coin icon
  Widget _buildCoinIcon(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: ColorConstants.secondary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '\$',
          style: TextStyle(
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}