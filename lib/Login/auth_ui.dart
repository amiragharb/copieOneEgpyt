// lib/Login/auth_ui.dart
import 'dart:ui';
import 'package:flutter/material.dart';

/// -------- Palette bleue + effets ----------
class AuthColors {
  // Teinte globale “nuit bleue”
  static const bgTintTop = Color(0xB30D2138);
  static const bgTintBot = Color(0xB30A1C31);

  // Halo chaud façon lampe
  static const lampWarm = Color(0xFFFFE2A3);

  // Carte verre bleutée
  static const cardTop = Color(0xCC2A4566);
  static const cardBot = Color(0xCC0F2749);

  // Formulaire
  static const cardBorder = Color(0x33FFFFFF);
  static const fieldFill  = Color(0x1FFFFFFF); // ~12% blanc
}

/// -------- Scaffold générique d’auth ----------
class AuthScaffold extends StatelessWidget {
  final Widget child;

  /// Image de fond (ex: 'images/login_bg.jpg'). Laisse null si tu veux un uni.
  final String? backgroundAsset;

  /// Couleur de fond quand aucune image. Ex: Colors.white (si tu veux un fond blanc).
  final Color? backgroundColor;

  /// Active/Désactive la teinte bleue + halo. (ON par défaut)
  final bool useBlueTint;

  /// Logo en haut.
  final String? topLogoAsset;
  final double topLogoHeight;
  final EdgeInsets topLogoPadding;

  /// Teinte du logo (utile si logo monochrome).
  final Color? topLogoTint;

  /// Petit fond arrondi derrière le logo.
  final Color? topLogoBackdrop;

  const AuthScaffold({
    Key? key,
    required this.child,
    this.backgroundAsset,
    this.backgroundColor,
    this.useBlueTint = true,
    this.topLogoAsset,
    this.topLogoHeight = 110,
    this.topLogoPadding = const EdgeInsets.only(top: 28),
    this.topLogoTint,
    this.topLogoBackdrop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // --- Couche de base
        if (backgroundColor != null)
          Container(color: backgroundColor)
        else if (backgroundAsset != null)
          Image.asset(backgroundAsset!, fit: BoxFit.cover)
        else
          Container(color: const Color(0xFF0B1E34)),

        // --- Teinte bleue optionnelle
        if (useBlueTint)
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AuthColors.bgTintTop, AuthColors.bgTintBot],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

        // --- Halo chaud optionnel
        if (useBlueTint) const _LampGlow(),

        // --- Logo
        if (topLogoAsset != null)
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: topLogoPadding,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: topLogoBackdrop,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: topLogoBackdrop == null ? 0 : 12,
                      vertical: topLogoBackdrop == null ? 0 : 6,
                    ),
                    child: Image.asset(
                      topLogoAsset!,
                      height: topLogoHeight,
                      color: topLogoTint,
                      colorBlendMode:
                          topLogoTint == null ? BlendMode.srcOver : BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),

        // --- Contenu centré
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

/// Halo radial chaud en haut (simule la lumière de la maquette)
class _LampGlow extends StatelessWidget {
  const _LampGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -1.05),
            radius: 1.15,
            colors: [
              const Color.fromARGB(255, 30, 64, 201).withOpacity(0.45),
              Colors.transparent,
            ],
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}

/// -------- Carte “verre” dégradée bleue ----------
class GlassCard extends StatelessWidget {
  final Widget child;
  const GlassCard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24);
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 26),
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: const LinearGradient(
              colors: [AuthColors.cardTop, AuthColors.cardBot],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(color: AuthColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.38),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          // léger reflet chaud en haut
          foregroundDecoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -1.15),
              radius: 1.25,
              colors: [
                AuthColors.lampWarm.withOpacity(0.12),
                Colors.transparent,
              ],
              stops: const [0.0, 1.0],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// -------- Champ arrondi ----------
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
    final baseSide = BorderSide(color: Colors.white.withOpacity(0.28));
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(28),
      borderSide: baseSide,
    );

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: AuthColors.fieldFill,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.85)),
        prefixIcon: Icon(icon, color: Colors.white),
        suffixIcon: onToggleObscure == null
            ? null
            : IconButton(
                onPressed: onToggleObscure,
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white,
                ),
              ),
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: Colors.white),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
    );
  }
}

/// -------- Bouton principal ----------
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
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color.fromARGB(255, 53, 83, 255),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        child: loading
            ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

/// -------- Carte Login réutilisable ----------
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
    return GlassCard(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 28),
            AuthTextField(
              controller: widget.emailController,
              hint: 'Username',
              icon: Icons.person_outline,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: widget.passwordController,
              hint: 'Password',
              icon: Icons.lock_outline,
              obscure: _obscure,
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              onToggleObscure: () => setState(() => _obscure = !_obscure),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: _remember,
                  onChanged: (v) {
                    setState(() => _remember = v ?? false);
                    widget.onRememberChanged?.call(_remember);
                  },
                  side: const BorderSide(color: Colors.white),
                  checkColor: const Color(0xFF0F2027),
                  activeColor: Colors.white,
                ),
                const Text('Remember me', style: TextStyle(color: Colors.white)),
                const Spacer(),
                TextButton(
                  onPressed: widget.onForgotPassword,
                  child: const Text('Forgot password?', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AuthButton(
              text: 'Login',
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
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account? ",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
                ),
                TextButton(
                  onPressed: widget.onRegister,
                  child: const Text(
                    'Register',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
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
