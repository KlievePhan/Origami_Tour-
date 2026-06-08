import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';

/// Register screen (`/register`).
///
/// UI ported from the Figma export; restructured into a real screen widget
/// with working form fields, live password-strength feedback, a functional
/// terms checkbox and navigation. Visual design (colors, type, spacing,
/// shape) is unchanged.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _showTermsError = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Re-render the strength meter and the confirm-password validity as the
    // user types, without forcing a full form validation pass each keystroke.
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged() => setState(() {});

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter your full name';
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email address';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // Validation rules per CLAUDE.md §11: ≥ 8 chars, ≥ 1 uppercase, ≥ 1 number.
  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Create a password';
    if (password.length < 8) return 'Use at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(password)) return 'Add at least one uppercase letter';
    if (!RegExp(r'[0-9]').hasMatch(password)) return 'Add at least one number';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Repeat your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  _PasswordStrength get _passwordStrength => _PasswordStrength.of(_passwordController.text);

  Future<void> _submitRegister() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    setState(() => _showTermsError = !_agreedToTerms);
    if (!formValid || !_agreedToTerms) return;

    setState(() => _isSubmitting = true);
    // TODO(agent): wire to AuthProvider.register (prov-auth is not_started yet).
    // Per CLAUDE.md §9-A, a successful register should auto sign-in and
    // redirect to /home/collection.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    _notifyPending('Registration');
  }

  void _notifyPending(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$feature is not wired up yet.')));
  }

  void _openLogin() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacement<void, void>(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF011D86)),
          onPressed: _openLogin,
          tooltip: 'Back to login',
        ),
        title: Text(
          'Create New Account',
          style: TextStyle(
            color: const Color(0xFF011D86),
            fontSize: 22,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            height: 1.27,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 512),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _HeroBanner(),
                  const SizedBox(height: 24),
                  _buildFormCard(context),
                  const SizedBox(height: 24),
                  const _PerksRow(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: ShapeDecoration(
        color: const Color(0xFFFBF8FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadows: const [
          BoxShadow(color: Color(0x0A24389C), blurRadius: 4, offset: Offset(0, 2)),
          BoxShadow(color: Color(0x1424389C), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FieldLabel('Full Name'),
            const SizedBox(height: 8),
            _AuthTextField(
              controller: _fullNameController,
              hintText: 'Enter your full name',
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.name,
              validator: _validateFullName,
            ),
            const SizedBox(height: 16),
            _FieldLabel('Email Address'),
            const SizedBox(height: 8),
            _AuthTextField(
              controller: _emailController,
              hintText: 'you@example.com',
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            const SizedBox(height: 16),
            _FieldLabel('Password'),
            const SizedBox(height: 8),
            _AuthTextField(
              controller: _passwordController,
              hintText: 'Create a strong password',
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              validator: _validatePassword,
              suffixIcon: _VisibilityToggle(
                obscured: _obscurePassword,
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            const SizedBox(height: 8),
            _PasswordStrengthMeter(strength: _passwordStrength),
            const SizedBox(height: 16),
            _FieldLabel('Confirm Password'),
            const SizedBox(height: 8),
            _AuthTextField(
              controller: _confirmPasswordController,
              hintText: 'Repeat your password',
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              validator: _validateConfirmPassword,
              onFieldSubmitted: (_) => _submitRegister(),
              suffixIcon: _VisibilityToggle(
                obscured: _obscureConfirmPassword,
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
            const SizedBox(height: 8),
            _TermsCheckbox(
              value: _agreedToTerms,
              showError: _showTermsError,
              onChanged: (value) => setState(() {
                _agreedToTerms = value;
                _showTermsError = false;
              }),
              onTermsTap: () => _notifyPending('Terms of Service'),
              onPrivacyTap: () => _notifyPending('Privacy Policy'),
            ),
            const SizedBox(height: 16),
            _PrimaryButton(
              label: 'Register',
              isLoading: _isSubmitting,
              onPressed: _submitRegister,
            ),
            const SizedBox(height: 16),
            const _OrDivider(),
            const SizedBox(height: 16),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: const Color(0xFF454652),
                      fontSize: 16,
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                  GestureDetector(
                    onTap: _openLogin,
                    child: Text(
                      'Login here',
                      style: TextStyle(
                        color: const Color(0xFF011D86),
                        fontSize: 16,
                        fontFamily: 'Work Sans',
                        fontWeight: FontWeight.w700,
                        height: 1.50,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Top illustration banner with the "Join the Folding Journey" headline.
class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: const BoxDecoration(
          // TODO(agent): replace with a real hero image from assets/illustrations/
          // once provided — this gradient stands in for the Figma placeholder.
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF24389C), Color(0xFF011D86)],
          ),
        ),
        child: Stack(
          children: [
            const Center(
              child: Icon(Icons.auto_awesome_mosaic_outlined, color: Colors.white24, size: 64),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [const Color(0x99011D86), const Color(0x00011D86)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Join the Folding Journey',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                        height: 1.50,
                        letterSpacing: -0.40,
                      ),
                    ),
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

/// Bottom highlight cards advertising "Daily Tutorials" / "Mastery Levels".
class _PerksRow extends StatelessWidget {
  const _PerksRow();

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        Expanded(
          child: _PerkCard(
            backgroundColor: Color(0xFFFDD274),
            titleColor: Color(0xFF775800),
            bodyColor: Color(0xFF775800),
            title: 'Daily Tutorials',
            body: 'Learn new folds daily.',
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _PerkCard(
            backgroundColor: Color(0xFF004C43),
            titleColor: Color(0xFF7EBBAF),
            bodyColor: Color(0xFF7EBBAF),
            title: 'Mastery Levels',
            body: 'Track your progress.',
          ),
        ),
      ],
      ),
    );
  }
}

class _PerkCard extends StatelessWidget {
  const _PerkCard({
    required this.backgroundColor,
    required this.titleColor,
    required this.bodyColor,
    required this.title,
    required this.body,
  });

  final Color backgroundColor;
  final Color titleColor;
  final Color bodyColor;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadows: const [BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontSize: 16,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w700,
              height: 1.50,
            ),
          ),
          const SizedBox(height: 8),
          Opacity(
            opacity: 0.80,
            child: Text(
              body,
              style: TextStyle(
                color: bodyColor,
                fontSize: 16,
                fontFamily: 'Work Sans',
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Field label, shared styling for "Full Name" / "Email Address" etc.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          color: const Color(0xFF454652),
          fontSize: 16,
          fontFamily: 'Work Sans',
          fontWeight: FontWeight.w400,
          height: 1.50,
        ),
      ),
    );
  }
}

/// Outlined text field matching the Figma input styling
/// (white fill, 1px `#C5C5D4` border, 12px radius).
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
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

class _VisibilityToggle extends StatelessWidget {
  const _VisibilityToggle({required this.obscured, required this.onPressed});

  final bool obscured;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: const Color(0xFF757684),
        size: 20,
      ),
      onPressed: onPressed,
      tooltip: obscured ? 'Show password' : 'Hide password',
    );
  }
}

/// Three-tier strength meter (Weak / Medium / Strong) driven by
/// [_PasswordStrength], replacing the static "Weak — at least 8 chars" bar
/// from the Figma export with a value that reacts to what the user types.
enum _PasswordStrengthLevel { empty, weak, medium, strong }

class _PasswordStrength {
  const _PasswordStrength(this.level, this.label, this.helper, this.color, this.fraction);

  final _PasswordStrengthLevel level;
  final String label;
  final String helper;
  final Color color;
  final double fraction;

  static _PasswordStrength of(String password) {
    if (password.isEmpty) {
      return const _PasswordStrength(
        _PasswordStrengthLevel.empty,
        'Weak',
        'At least 8 chars, 1 uppercase, 1 number',
        Color(0xFFBA1A1A),
        0.0,
      );
    }
    var score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password) && password.length >= 12) score++;

    return switch (score) {
      <= 1 => const _PasswordStrength(
          _PasswordStrengthLevel.weak,
          'Weak',
          'At least 8 chars, 1 uppercase, 1 number',
          Color(0xFFBA1A1A),
          0.25,
        ),
      2 => const _PasswordStrength(
          _PasswordStrengthLevel.medium,
          'Medium',
          'Add a number or an uppercase letter',
          Color(0xFF785900),
          0.6,
        ),
      _ => const _PasswordStrength(
          _PasswordStrengthLevel.strong,
          'Strong',
          'Looks good!',
          Color(0xFF004C43),
          1.0,
        ),
    };
  }
}

class _PasswordStrengthMeter extends StatelessWidget {
  const _PasswordStrengthMeter({required this.strength});

  final _PasswordStrength strength;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(9999),
          child: LinearProgressIndicator(
            value: strength.fraction,
            minHeight: 4,
            backgroundColor: const Color(0xFFE9E7F0),
            valueColor: AlwaysStoppedAnimation<Color>(strength.color),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strength.label,
                style: TextStyle(
                  color: strength.color,
                  fontSize: 16,
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
              Flexible(
                child: Text(
                  strength.helper,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: const Color(0xFF757684),
                    fontSize: 16,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// "I agree to the Terms of Service and Privacy Policy" checkbox row with
/// tappable links — the Figma export rendered this as a static box + text.
class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({
    required this.value,
    required this.showError,
    required this.onChanged,
    required this.onTermsTap,
    required this.onPrivacyTap,
  });

  final bool value;
  final bool showError;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;

  static const _bodyStyle = TextStyle(
    color: Color(0xFF454652),
    fontSize: 16,
    fontFamily: 'Work Sans',
    fontWeight: FontWeight.w400,
    height: 1.25,
  );

  static const _linkStyle = TextStyle(
    color: Color(0xFF011D86),
    fontSize: 16,
    fontFamily: 'Work Sans',
    fontWeight: FontWeight.w400,
    height: 1.25,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: (checked) => onChanged(checked ?? false),
                activeColor: const Color(0xFF011D86),
                side: const BorderSide(width: 1, color: Color(0xFF757684)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(!value),
                behavior: HitTestBehavior.translucent,
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'I agree to the ', style: _bodyStyle),
                      TextSpan(
                        text: 'Terms of Service',
                        style: _linkStyle,
                        recognizer: TapGestureRecognizer()..onTap = onTermsTap,
                      ),
                      const TextSpan(text: '\nand ', style: _bodyStyle),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: _linkStyle,
                        recognizer: TapGestureRecognizer()..onTap = onPrivacyTap,
                      ),
                      const TextSpan(text: '.', style: _bodyStyle),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (showError)
          const Padding(
            padding: EdgeInsets.only(left: 32, top: 4),
            child: Text(
              'You must agree to continue.',
              style: TextStyle(
                color: Color(0xFFBA1A1A),
                fontSize: 14,
                fontFamily: 'Work Sans',
                fontWeight: FontWeight.w400,
                height: 1.43,
              ),
            ),
          ),
      ],
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
              )
            : Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
      ),
    );
  }
}

/// "—— OR ——" divider between the form and the secondary "Login here" link.
class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(height: 1, color: Color(0xFFEDEEEF))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: const Color(0xFF757684),
              fontSize: 16,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
          ),
        ),
        const Expanded(child: Divider(height: 1, color: Color(0xFFEDEEEF))),
      ],
    );
  }
}
