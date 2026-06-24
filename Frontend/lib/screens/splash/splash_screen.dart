import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../shell/shell_screen.dart';

/// Splash screen shown while the app boots.
///
/// Styled from the "Craft-Tech" / "Paper-on-Paper" brand tokens in
/// `.agent/Design.md` (indigo-structural `#24389C`, amber-energy `#FDC003`,
/// Plus Jakarta Sans / Work Sans). Holds for at least [_displayDuration]
/// while [AuthProvider.restoreSession] checks for a saved session, then
/// routes to Login (no session) or the Shell (session restored).
///
/// TODO(agent): once routing (`go_router`, CLAUDE.md §8) exists, replace this
/// hard navigation with a real auth-gated redirect.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _displayDuration = Duration(seconds: 7);
  static const _introDuration = Duration(milliseconds: 900);

  late final AnimationController _introController;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Future<void> _restoreSessionFuture;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: _introDuration,
    );
    _fade = CurvedAnimation(parent: _introController, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _introController, curve: Curves.easeOutBack),
    );
    _introController.forward();
    _restoreSessionFuture = context.read<AuthProvider>().restoreSession();
    _navigationTimer = Timer(_displayDuration, _navigateNext);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _introController.dispose();
    super.dispose();
  }

  Future<void> _navigateNext() async {
    await _restoreSessionFuture;
    if (!mounted) return;
    final isAuthenticated =
        context.read<AuthProvider>().status == AuthStatus.authenticated;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            isAuthenticated ? const ShellScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF24389C),
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _BrandMark(),
                const SizedBox(height: 24),
                Text(
                  'Origami Tour',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fold. Learn. Master.',
                  style: const TextStyle(
                    color: Color(0xCCFFFFFF),
                    fontSize: 14,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.25,
                  ),
                ),
                const SizedBox(height: 40),
                const _CreaseLineLoader(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Logo placeholder evoking the brand's "Paper-on-Paper" fold motif: a
/// paper-white card with a rotated amber-energy square at its center.
///
/// TODO(agent): swap for the real app icon/logo once provided.
class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Transform.rotate(
          angle: 0.785398, // 45°, suggesting a folded corner
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFDC003),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}

/// Indeterminate loading indicator styled like a "crease line" — a thin
/// amber-on-indigo pill bar — per Design.md ("Progress Steppers: Mimic a
/// crease line").
class _CreaseLineLoader extends StatelessWidget {
  const _CreaseLineLoader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9999),
        child: const LinearProgressIndicator(
          minHeight: 4,
          backgroundColor: Color(0x33FFFFFF),
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFDC003)),
        ),
      ),
    );
  }
}
