import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/bookmark_provider.dart';
import '../collection/collection_screen.dart';
import 'recover_password_screen.dart';
import 'register_screen.dart';
import '../../widgets/google_auth_button.dart';

/// Login screen (`/login`).
///
/// UI ported from the Figma export; restructured into a real screen widget
/// with working form fields, validation, password visibility toggle and
/// navigation. Visual design (colors, type, spacing, shape) is unchanged.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _loginError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email address';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter your password';
    // Surfaces the server's "Incorrect email or password" error inline,
    // beneath the field, instead of as a snackbar.
    return _loginError;
  }

  Future<void> _submitLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isSubmitting = true;
      _loginError = null;
    });
    final error = await context.read<AuthProvider>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _loginError = error;
    });
    if (error == null) {
      context.read<BookmarkProvider>().load();
      _goToShellAfterLogin();
    } else {
      _formKey.currentState?.validate();
    }
  }

  /// Successful login replaces this screen so the back gesture can't return
  /// to it (unlike `_openMainMenu`, the "Continue to main menu" dev bypass).
  void _goToShellAfterLogin() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const CollectionScreen()));
  }



  void _openRegister() {
    Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => const RegisterScreen()));
  }

  void _openRecoverPassword() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const RecoverPasswordScreen()),
    );
  }

  void _openMainMenu() {
    Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => const CollectionScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          const Positioned.fill(child: _BackgroundDecoration()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const _Branding(),
                      const SizedBox(height: 32),
                      _buildCard(context),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _openMainMenu,
                        child: Text(
                          'Continue to main menu',
                          style: TextStyle(
                            color: const Color(0xFF011D86),
                            fontSize: 14,
                            fontFamily: 'Work Sans',
                            fontWeight: FontWeight.w500,
                            height: 1.43,
                            letterSpacing: 0.10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadows: const [
          BoxShadow(
            color: Color(0x0C24389C),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x1424389C),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0x0024389C),
                    Color(0x0C24389C),
                    Color(0x0024389C),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome Back',
              style: TextStyle(
                color: const Color(0xFF1A1B21),
                fontSize: 22,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w500,
                height: 1.27,
              ),
            ),
            Text(
              'Please enter your details to continue',
              style: TextStyle(
                color: const Color(0xFF454652),
                fontSize: 14,
                fontFamily: 'Work Sans',
                fontWeight: FontWeight.w400,
                height: 1.43,
                letterSpacing: 0.25,
              ),
            ),
            const SizedBox(height: 24),
            _FieldLabel('Email Address'),
            const SizedBox(height: 8),
            _AuthTextField(
              controller: _emailController,
              hintText: 'name@example.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: _validateEmail,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _FieldLabel('Password'),
                GestureDetector(
                  onTap: _openRecoverPassword,
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: const Color(0xFF011D86),
                      fontSize: 14,
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w500,
                      height: 1.43,
                      letterSpacing: 0.10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _AuthTextField(
              controller: _passwordController,
              hintText: '••••••••',
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              validator: _validatePassword,
              onFieldSubmitted: (_) => _submitLogin(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF757684),
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                tooltip: _obscurePassword ? 'Show password' : 'Hide password',
              ),
            ),
            const SizedBox(height: 16),
            _PrimaryButton(
              label: 'Login',
              isLoading: _isSubmitting,
              onPressed: _submitLogin,
            ),
            const SizedBox(height: 16),
            const _OrDivider(),
            const SizedBox(height: 16),
            const GoogleAuthButton(isLogin: true),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 24),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(width: 1, color: Color(0xFFEDEEEF)),
                ),
              ),
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Text(
                      'Do not have an account? ',
                      style: TextStyle(
                        color: const Color(0xFF454652),
                        fontSize: 14,
                        fontFamily: 'Work Sans',
                        fontWeight: FontWeight.w400,
                        height: 1.43,
                        letterSpacing: 0.25,
                      ),
                    ),
                    GestureDetector(
                      onTap: _openRegister,
                      child: Text(
                        'Register New Account',
                        style: TextStyle(
                          color: const Color(0xFF011D86),
                          fontSize: 14,
                          fontFamily: 'Work Sans',
                          fontWeight: FontWeight.w700,
                          height: 1.43,
                          letterSpacing: 0.10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Branding extends StatelessWidget {
  const _Branding();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x0C24389C),
                blurRadius: 6,
                offset: Offset(0, 4),
              ),
              BoxShadow(
                color: Color(0x1424389C),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          // TODO(agent): swap for the real brand mark once an asset is provided
          // (assets/illustrations/); this gradient stands in for the Figma artwork.
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.10,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF011D86),
                          const Color(0x00011D86),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 48,
                top: 0,
                child: Opacity(
                  opacity: 0.50,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFE9E7F0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(9999),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Center(
                child: Icon(
                  Icons.auto_awesome_mosaic_outlined,
                  color: Color(0xFF011D86),
                  size: 28,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Origami Tour',
          style: TextStyle(
            color: const Color(0xFF011D86),
            fontSize: 28,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
            height: 1.29,
            letterSpacing: -0.70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Fold your next adventure',
          style: TextStyle(
            color: const Color(0xFF454652),
            fontSize: 14,
            fontFamily: 'Work Sans',
            fontWeight: FontWeight.w500,
            height: 1.43,
            letterSpacing: 0.10,
          ),
        ),
      ],
    );
  }
}

/// Decorative background blobs + radial wash, sized to the viewport instead
/// of the fixed 390x945 Figma canvas so it no longer clips/overflows on other
/// device sizes.
class _BackgroundDecoration extends StatelessWidget {
  const _BackgroundDecoration();

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          Positioned(
            right: -90,
            top: 58,
            child: Transform.rotate(
              angle: 0.26,
              child: Container(
                width: 320,
                height: 320,
                decoration: ShapeDecoration(
                  color: const Color(0x0C011D86),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: const ShapeDecoration(
                color: Color(0x0CFDC003),
                shape: CircleBorder(),
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.71,
                    colors: [const Color(0xFF24389C), const Color(0x0024389C)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Field label, shared styling for "Email Address" / "Password" etc.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: const Color(0xFF454652),
        fontSize: 14,
        fontFamily: 'Work Sans',
        fontWeight: FontWeight.w500,
        height: 1.43,
        letterSpacing: 0.10,
      ),
    );
  }
}

/// Outlined text field matching the Figma input styling
/// (fill `#FBF8FF`, 1px `#C5C5D4` border, 12px radius).
class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(
        color: Color(0xFF1A1B21),
        fontSize: 16,
        fontFamily: 'Work Sans',
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0x7F757684),
          fontSize: 16,
          fontFamily: 'Work Sans',
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: const Color(0xFFFBF8FF),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 1, color: Color(0xFFC5C5D4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 1, color: Color(0xFFC5C5D4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 2, color: Color(0xFF011D86)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 1, color: Color(0xFFBA1A1A)),
        ),
      ),
    );
  }
}

/// Solid indigo CTA button (`Login` / `Register`) with loading state.
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF011D86),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF011D86),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w500,
                  height: 1.43,
                  letterSpacing: 0.10,
                ),
              ),
      ),
    );
  }
}

/// "—— OR ——" divider between primary auth and social sign-in.
class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(height: 1, color: Color(0xFFE3E1EA))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: const Color(0xFF757684),
              fontSize: 11,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w500,
              height: 1.45,
              letterSpacing: 1.10,
            ),
          ),
        ),
        const Expanded(child: Divider(height: 1, color: Color(0xFFE3E1EA))),
      ],
    );
  }
}
