import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Recover Password screen (`/recover`).
///
/// UI ported from the Figma export; restructured into a real screen widget
/// with a working email step (validation + 60s resend cooldown) and a
/// working 6-digit OTP step (auto-advancing inputs + verify). Visual design
/// (colors, type, spacing, shape) is unchanged.
///
/// TODO(agent): the Figma upload only covers Phase 1 (email -> OTP). Per
/// CLAUDE.md §9-A, a verified OTP should switch this same screen to a
/// Phase 2 "set new password" step — add that UI once its design lands.
class RecoverPasswordScreen extends StatefulWidget {
  const RecoverPasswordScreen({super.key});

  @override
  State<RecoverPasswordScreen> createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  static const _otpLength = 6;
  static const _cooldownDuration = Duration(seconds: 60);

  final _emailFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpControllers = List.generate(_otpLength, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(_otpLength, (_) => FocusNode());

  Timer? _cooldownTimer;
  int _cooldownSeconds = 0;
  bool _otpSent = false;
  bool _isSendingOtp = false;
  bool _isVerifying = false;
  String? _otpError;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _emailController.dispose();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your registered email address';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldownSeconds = _cooldownDuration.inSeconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        setState(() => _cooldownSeconds = 0);
      } else {
        setState(() => _cooldownSeconds -= 1);
      }
    });
  }

  Future<void> _sendOtp() async {
    if (!(_emailFormKey.currentState?.validate() ?? false)) return;
    setState(() => _isSendingOtp = true);
    // TODO(agent): wire to AuthProvider.sendOtp (prov-auth is not_started yet).
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _isSendingOtp = false;
      _otpSent = true;
      _otpError = null;
    });
    _startCooldown();
    _notifyPending('Sending the verification code');
    FocusScope.of(context).requestFocus(_otpFocusNodes.first);
  }

  Future<void> _verifyOtp() async {
    final code = _otpControllers.map((c) => c.text).join();
    if (!_otpSent) {
      setState(() => _otpError = 'Send a verification code first');
      return;
    }
    if (code.length != _otpLength) {
      setState(() => _otpError = 'Enter the full $_otpLength-digit code');
      return;
    }
    setState(() {
      _otpError = null;
      _isVerifying = true;
    });
    // TODO(agent): wire to AuthProvider.verifyOtp (prov-auth is not_started
    // yet); on success this screen should switch to the "set new password"
    // step per CLAUDE.md §9-A (design not yet provided).
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _isVerifying = false);
    _notifyPending('Verifying the code');
  }

  void _onOtpDigitChanged(int index, String value) {
    if (_otpError != null) setState(() => _otpError = null);
    if (value.isNotEmpty && index < _otpLength - 1) {
      _otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }
  }

  void _notifyPending(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$feature is not wired up yet.')));
  }

  String get _resendLabel {
    final minutes = _cooldownSeconds ~/ 60;
    final seconds = _cooldownSeconds % 60;
    return 'Resend in $minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF011D86)),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Back to login',
        ),
        title: Text(
          'Recover Password',
          style: TextStyle(
            color: const Color(0xFF011D86),
            fontSize: 22,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            height: 1.27,
            letterSpacing: 0.25,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFE9E7F0),
              child: const Icon(Icons.person_outline, color: Color(0xFF757684)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 512),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const _RecoveryIllustration(),
                  const SizedBox(height: 24),
                  Text(
                    'Forgot security code?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF1A1B21),
                      fontSize: 28,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w600,
                      height: 1.29,
                      letterSpacing: 0.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Text(
                      'Enter your registered email address to\nreceive a 6-digit verification code.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF454652),
                        fontSize: 16,
                        fontFamily: 'Work Sans',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                        letterSpacing: 0.50,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildCard(context),
                  const SizedBox(height: 24),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          'Need more help? ',
                          style: TextStyle(
                            color: const Color(0xFF454652),
                            fontSize: 14,
                            fontFamily: 'Work Sans',
                            fontWeight: FontWeight.w500,
                            height: 1.43,
                            letterSpacing: 0.10,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _notifyPending('Contact Support'),
                          child: Text(
                            'Contact Support',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0x4CE3E1EA)),
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: const [
          BoxShadow(color: Color(0x19000000), blurRadius: 6, offset: Offset(0, 4)),
          BoxShadow(color: Color(0x19000000), blurRadius: 15, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Form(
            key: _emailFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel('Email Address'),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        enabled: !_otpSent,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        validator: _validateEmail,
                        onFieldSubmitted: (_) => _sendOtp(),
                        style: const TextStyle(
                          color: Color(0xFF1A1B21),
                          fontSize: 16,
                          fontFamily: 'Work Sans',
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintText: 'example@origami.com',
                          hintStyle: const TextStyle(
                            color: Color(0x7F454652),
                            fontSize: 16,
                            fontFamily: 'Work Sans',
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.25,
                          ),
                          prefixIcon: const Icon(Icons.mail_outline, color: Color(0xFF757684)),
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17.5),
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
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: (_isSendingOtp || (_otpSent && _cooldownSeconds > 0)) ? null : _sendOtp,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF795901),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      _isSendingOtp
                          ? 'Sending…'
                          : _otpSent
                              ? 'Resend OTP'
                              : 'Send OTP',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Work Sans',
                        fontWeight: FontWeight.w500,
                        height: 1.43,
                        letterSpacing: 0.10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _FieldLabel('Verification Code'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < _otpLength; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: _OtpDigitField(
                  controller: _otpControllers[i],
                  focusNode: _otpFocusNodes[i],
                  enabled: _otpSent,
                  hasError: _otpError != null,
                  onChanged: (value) => _onOtpDigitChanged(i, value),
                )),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: _otpError != null
                ? Text(
                    _otpError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFBA1A1A),
                      fontSize: 11,
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                      letterSpacing: 0.50,
                    ),
                  )
                : Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Did not receive the code? ',
                          style: TextStyle(
                            color: const Color(0xFF454652),
                            fontSize: 11,
                            fontFamily: 'Work Sans',
                            fontWeight: FontWeight.w500,
                            height: 1.45,
                            letterSpacing: 0.50,
                          ),
                        ),
                        if (_otpSent && _cooldownSeconds > 0)
                          TextSpan(
                            text: _resendLabel,
                            style: const TextStyle(
                              color: Color(0xFF795901),
                              fontSize: 11,
                              fontFamily: 'Work Sans',
                              fontWeight: FontWeight.w500,
                              height: 1.45,
                              letterSpacing: 0.50,
                            ),
                          )
                        else
                          TextSpan(
                            text: 'Resend now',
                            style: const TextStyle(
                              color: Color(0xFF011D86),
                              fontSize: 11,
                              fontFamily: 'Work Sans',
                              fontWeight: FontWeight.w700,
                              height: 1.45,
                              letterSpacing: 0.50,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = _isSendingOtp ? null : _sendOtp,
                          ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isVerifying ? null : _verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF011D86),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF011D86),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                elevation: 3,
              ),
              child: _isVerifying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                    )
                  : Text(
                      'Verify',
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
          ),
        ],
      ),
    );
  }
}

/// Soft indigo "envelope" illustration that replaces the Figma placeholder
/// image — keeps the same 192x192 card + radial-gradient wash treatment.
class _RecoveryIllustration extends StatelessWidget {
  const _RecoveryIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 192,
      height: 192,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFFF4F2FC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadows: const [BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.10,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 0.71,
                    colors: [const Color(0xFF011D86), const Color(0x00011D86)],
                  ),
                ),
              ),
            ),
          ),
          // TODO(agent): swap for the real illustration from assets/illustrations/
          // once provided; this icon stands in for the Figma placeholder image.
          const Icon(Icons.mark_email_read_outlined, size: 72, color: Color(0xFF011D86)),
        ],
      ),
    );
  }
}

/// Field label, shared styling for "Email Address" / "Verification Code".
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
          color: const Color(0xFF011D86),
          fontSize: 14,
          fontFamily: 'Work Sans',
          fontWeight: FontWeight.w500,
          height: 1.43,
          letterSpacing: 0.10,
        ),
      ),
    );
  }
}

/// Single OTP digit box — the Figma export rendered these as six empty,
/// non-interactive decorated containers; this is a real auto-advancing input.
class _OtpDigitField extends StatelessWidget {
  const _OtpDigitField({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.hasError,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final bool hasError;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final borderColor = hasError ? const Color(0xFFBA1A1A) : const Color(0xFFC5C5D4);
    return AspectRatio(
      aspectRatio: 1,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        textAlign: TextAlign.center,
        maxLength: 1,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onChanged,
        style: const TextStyle(
          color: Color(0xFF1A1B21),
          fontSize: 20,
          fontFamily: 'Work Sans',
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: enabled ? Colors.white : const Color(0xFFEDEEEF),
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(width: 1, color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(width: 1, color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(width: 2, color: Color(0xFF011D86)),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(width: 1, color: Color(0xFFEDEEEF)),
          ),
        ),
      ),
    );
  }
}
