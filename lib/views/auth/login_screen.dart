import 'package:eco_coins_mobile_app/controllers/auth_controller.dart';
import 'package:eco_coins_mobile_app/utils/constants.dart';
import 'package:eco_coins_mobile_app/utils/helpers.dart';
import 'package:eco_coins_mobile_app/views/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Login screen for user authentication
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handle login button press
  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authController =
          Provider.of<AuthController>(context, listen: false);
      final success = await authController.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, AppConstants.dashboardRoute);
      } else if (mounted) {
        Helpers.showSnackBar(
          context,
          authController.errorMessage ?? 'Login failed',
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
                _buildWelcomeMessage(),
                const SizedBox(height: 32),
                _buildLoginForm(),
                const SizedBox(height: 16),
                _buildForgotPassword(),
                const SizedBox(height: 24),
                _buildLoginButton(),
                const SizedBox(height: 24),
                _buildSignUpLink(),
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
    return const Column(
      children: [
        Icon(
          Icons.eco,
          size: 80,
          color: ColorConstants.primary,
        ),
        SizedBox(height: 16),
        Text(
          AppConstants.appName,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: ColorConstants.primary,
          ),
        ),
      ],
    );
  }

  /// Build welcome message
  Widget _buildWelcomeMessage() {
    return const Text(
      AppConstants.welcomeMessage,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: ColorConstants.textPrimary,
      ),
    );
  }

  /// Build login form
  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email label
          const Text(
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
          const Text(
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
                return 'Please enter your password';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  /// Build forgot password link
  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // Show a snackbar message - this would typically navigate to a password reset screen
          Helpers.showSnackBar(
            context,
            'Password reset functionality coming soon!',
          );
        },
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            color: ColorConstants.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Build login button
  Widget _buildLoginButton() {
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        final bool isLoading = authController.state == AuthState.loading;
        return CustomButton(
          text: 'SIGN IN',
          onPressed: _handleLogin,
          isLoading: isLoading,
        );
      },
    );
  }

  /// Build sign up link
  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(
            color: ColorConstants.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppConstants.signupRoute);
          },
          child: const Text(
            'Create Account',
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
