import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:egpycopsversion4/l10n/app_localizations.dart';
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:flutter/widgets.dart';

/// -------- Modern Color Palette with your primary colors ----------
class AuthColors {
  // Main background gradients using your primary colors
  static final bgGradientTop = primaryDarkColor.withOpacity(0.95);
  static final bgGradientBottom = primaryColor.withOpacity(0.9);
  
  // Accent highlights
  static final accentGlow = logoBlue.withOpacity(0.3);
  static final accentBright = logoBlue;
  
  // Card design
  static const cardBackground = Color(0xFFFFFFFF);
  static const cardShadow = Color(0x1A000000);
  
  // Form fields
  static final fieldBorder = primaryColor.withOpacity(0.2);
  static final fieldFocused = primaryDarkColor;
  static final fieldFill = primaryColor.withOpacity(0.05);
  
  // Text colors
  static final textPrimary = primaryDarkColor;
  static final textSecondary = greyColor;
  static const textWhite = Colors.white;
}

/// -------- Modern Auth Scaffold ----------
class AuthScaffold extends StatelessWidget {
  final Widget child;
  final String? backgroundAsset;
  final Color? backgroundColor;
  final String? topLogoAsset;
  final double topLogoHeight;
  final EdgeInsets topLogoPadding;

  const AuthScaffold({
    Key? key,
    required this.child,
    this.backgroundAsset,
    this.backgroundColor,
    this.topLogoAsset,
    this.topLogoHeight = 120,
    this.topLogoPadding = const EdgeInsets.only(top: 40),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AuthColors.bgGradientTop,
              AuthColors.bgGradientBottom,
              primaryColor.withOpacity(0.8),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Floating circles decoration
            const _FloatingCircles(),
            
            // Logo at top
            if (topLogoAsset != null)
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: topLogoPadding,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        topLogoAsset!,
                        height: topLogoHeight,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            
            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating decorative circles
class _FloatingCircles extends StatelessWidget {
  const _FloatingCircles();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top right circle
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  logoBlue.withOpacity(0.3),
                  logoBlue.withOpacity(0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),
        ),
        
        // Bottom left circle
        Positioned(
          bottom: -80,
          left: -80,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  primaryColor.withOpacity(0.2),
                  primaryColor.withOpacity(0.05),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
        ),
        
        // Middle right small circle
        Positioned(
          top: MediaQuery.of(context).size.height * 0.4,
          right: -30,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// -------- Modern Glass Card ----------
class GlassCard extends StatelessWidget {
  final Widget child;
  const GlassCard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AuthColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// -------- Modern Text Field ----------
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final VoidCallback? onToggleObscure;

  const AuthTextField({
    Key? key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onToggleObscure,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: TextStyle(
          color: Colors.black87, // Dark text for perfect visibility
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        validator: validator,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white, // Solid white background for visibility
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey[600], // Darker hint text for visibility
            fontSize: 16,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              icon,
              color: primaryColor,
              size: 22,
            ),
          ),
          suffixIcon: onToggleObscure == null
              ? null
              : IconButton(
                  onPressed: onToggleObscure,
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[600], // Darker icon for visibility
                  ),
                ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.3), // Light grey border
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: primaryDarkColor, // Your primary color for focus
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: accentColor,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: accentColor,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }
}

/// -------- Modern Primary Button ----------
class AuthButton extends StatelessWidget {
  final String text;
  final bool loading;
  final VoidCallback onPressed;

  const AuthButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.loading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [primaryDarkColor, primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}

/// -------- Modern Login Card ----------
class LoginCard extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool remember;
  final ValueChanged<bool>? onRememberChanged;
  final VoidCallback onForgotPassword;
  final VoidCallback onRegister;
  final Future<void> Function(String email, String password, bool remember) onSubmit;
  final bool loading;
  final String title;

  const LoginCard({
    Key? key,
    required this.emailController,
    required this.passwordController,
    required this.onForgotPassword,
    required this.onRegister,
    required this.onSubmit,
    this.remember = false,
    this.onRememberChanged,
    this.loading = false,
    this.title = 'Login',
  }) : super(key: key);

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  late bool _remember;

  @override
  void initState() {
    super.initState();
    _remember = widget.remember;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return GlassCard(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Welcome text
            Text(
              'Welcome Back',
              style: TextStyle(
                color: AuthColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            
            // Title
            Text(
              widget.title,
              style: TextStyle(
                color: AuthColors.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 32),
            
            // Email field
            AuthTextField(
              controller: widget.emailController,
              hint: t?.username ?? 'Username or Email',
              icon: Icons.person_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? (t?.required ?? 'Required')
                  : null,
            ),
            const SizedBox(height: 20),
            
            // Password field
            AuthTextField(
              controller: widget.passwordController,
              hint: t?.password ?? 'Password',
              icon: Icons.lock_outline_rounded,
              obscure: _obscure,
              validator: (v) => (v == null || v.isEmpty)
                  ? (t?.required ?? 'Required')
                  : null,
              onToggleObscure: () => setState(() => _obscure = !_obscure),
            ),
            const SizedBox(height: 16),
            
            // Remember me and forgot password row
            Row(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() => _remember = !_remember);
                      widget.onRememberChanged?.call(_remember);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _remember ? primaryColor : AuthColors.fieldBorder,
                                width: 2,
                              ),
                              color: _remember ? primaryColor : Colors.transparent,
                            ),
                            child: _remember
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            t?.rememberMe ?? 'Remember me',
                            style: TextStyle(
                              color: AuthColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: widget.onForgotPassword,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  child: Text(
                    t?.forgotPassword ?? 'Forgot password?',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Login button
            AuthButton(
              text: t?.login ?? 'Login',
              loading: widget.loading,
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  await widget.onSubmit(
                    widget.emailController.text.trim(),
                    widget.passwordController.text,
                    _remember,
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            
            // Divider
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: AuthColors.fieldBorder,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'or',
                    style: TextStyle(
                      color: AuthColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: AuthColors.fieldBorder,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Register link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  t?.donNotHaveAccount ?? "Don't have an account? ",
                  style: TextStyle(
                    color: AuthColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton(
                  onPressed: widget.onRegister,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  child: Text(
                    t?.register ?? 'Register',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
