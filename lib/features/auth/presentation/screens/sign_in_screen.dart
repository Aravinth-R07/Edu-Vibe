import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/bubble_background.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';
import 'sign_up_screen.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  ConsumerState createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _isLoading = false;
  bool _isButtonEnabled = false;
  String? _emailError;
  String? _passwordError;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateFields);
    _passwordController.addListener(_validateFields);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuint,
    ));
    _animationController.forward();
  }

  void _validateFields() {
    setState(() {
      // Email validation
      if (_emailController.text.trim().isEmpty) {
        _emailError = 'Email is required';
      } else if (!_isValidEmail(_emailController.text.trim())) {
        _emailError = 'Please enter a valid email';
      } else {
        _emailError = null;
      }

      // Password validation
      if (_passwordController.text.trim().isEmpty) {
        _passwordError = 'Password is required';
      } else if (_passwordController.text.trim().length < 6) {
        _passwordError = 'Password must be at least 6 characters';
      } else {
        _passwordError = null;
      }

      // Enable button if both fields are valid
      _isButtonEnabled = _emailError == null &&
          _passwordError == null &&
          _emailController.text.trim().isNotEmpty &&
          _passwordController.text.trim().isNotEmpty;
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _signIn() {
    if (!_isButtonEnabled) return;
    setState(() => _isLoading = true);
    ref.read(authProvider.notifier).signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, current) {
      if (current.state == AuthState.error) {
        _showError(current.errorMessage ?? 'An error occurred');
      }
      setState(() {
        _isLoading = current.state == AuthState.loading;
      });
    });

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar:  CupertinoNavigationBar(
        middle: Text(AppStrings.signIn),
        backgroundColor: CupertinoColors.systemBackground.withOpacity(0.8),
      ),
      child: Stack(
        children: [
          // Animated bubble background
          const BubbleBackground(),

          // Content with slide animation
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 50),
                        _buildHeader(),
                        const SizedBox(height: 40),
                        _buildTextFields(),
                        const SizedBox(height: 32),
                        _buildSignInButton(),
                        const SizedBox(height: 16),
                        _buildForgotPassword(),
                        const SizedBox(height: 24),
                        _buildDivider(),
                        const SizedBox(height: 24),
                        _buildSignUpLink(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: CupertinoColors.activeBlue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            CupertinoIcons.book_fill,
            size: 40,
            color: CupertinoColors.activeBlue,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "Welcome Back!",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.activeBlue,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Sign in to continue learning",
          style: TextStyle(
            fontSize: 16,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildTextFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthTextField(
          controller: _emailController,
          focusNode: _emailFocus,
          placeholder: AppStrings.email,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: CupertinoIcons.mail_solid,
          errorText: _emailError,
          onSubmitted: (_) => _passwordFocus.requestFocus(),
        ),
        const SizedBox(height: 20),
        AuthTextField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          placeholder: AppStrings.password,
          isPassword: true,
          prefixIcon: CupertinoIcons.lock_fill,
          errorText: _passwordError,
          onSubmitted: (_) => _signIn(),
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 50,
      child: _isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : CupertinoButton.filled(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(12),
        onPressed: _isButtonEnabled ? _signIn : null,
        disabledColor: CupertinoColors.systemGrey.withOpacity(0.3),
        child: const Text(
          AppStrings.signIn,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Center(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        child: const Text(
          "Forgot Password?",
          style: TextStyle(
            fontSize: 14,
            color: CupertinoColors.activeBlue,
          ),
        ),
        onPressed: () {
          // TODO: Navigate to forgot password screen
        },
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: const [
        Expanded(
          child: Divider(
            color: CupertinoColors.systemGrey4,
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "OR",
            style: TextStyle(
              color: CupertinoColors.systemGrey,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: CupertinoColors.systemGrey4,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(
            color: CupertinoColors.systemGrey,
            fontSize: 15,
          ),
        ),
        CupertinoButton(
          padding: const EdgeInsets.only(left: 5),
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => const SignUpScreen(),
              ),
            );
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(
              color: CupertinoColors.activeBlue,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}