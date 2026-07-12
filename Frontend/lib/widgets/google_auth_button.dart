import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/bookmark_provider.dart';
import '../screens/collection/collection_screen.dart';

class GoogleAuthButton extends StatefulWidget {
  const GoogleAuthButton({super.key, this.isLogin = true});
  final bool isLogin;

  @override
  State<GoogleAuthButton> createState() => _GoogleAuthButtonState();
}

class _GoogleAuthButtonState extends State<GoogleAuthButton> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    
    try {
      final webClientId = '312065515197-nmo8ilbslcetb4lj2b6gi5obulos4bi3.apps.googleusercontent.com';
      await GoogleSignIn.instance.initialize(
        clientId: kIsWeb || Platform.isIOS ? webClientId : null,
        serverClientId: webClientId,
      );

      final account = await GoogleSignIn.instance.authenticate();
      final auth = account.authentication;
      if (auth.idToken == null) {
        throw Exception('Failed to get ID token from Google.');
      }

      if (!mounted) return;

      final error = await context.read<AuthProvider>().googleLogin(auth.idToken!);
      if (!mounted) return;

      if (error == null) {
        context.read<BookmarkProvider>().load();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const CollectionScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error)));
      }
    } on GoogleSignInException catch (e) {
      if (!mounted) return;
      if (e.code == GoogleSignInExceptionCode.canceled || 
          e.code == GoogleSignInExceptionCode.interrupted) {
        return;
      }
      if (e.code == GoogleSignInExceptionCode.unknownError || e.code.name.toLowerCase().contains('unknown')) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(
            content: Text('Google Login error: Missing SHA-1 fingerprint (or wrong Client ID). Please use Email login for testing.'),
            duration: Duration(seconds: 4),
          ));
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Google Sign-In failed: ${e.code}')));
    } on Exception catch (e) {
      if (!mounted) return;
      final errorStr = e.toString();
      if (errorStr.contains('ApiException: 10') || errorStr.contains('unknown')) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(
            content: Text('Google Login error: Missing SHA-1 fingerprint. Please use Email login for testing.'),
            duration: Duration(seconds: 4),
          ));
      } else {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('Google Sign-In failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _handleGoogleSignIn,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFC5C5D4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/24px-Google_%22G%22_logo.svg.png',
                    width: 24,
                    height: 24,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, size: 24, color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.isLogin ? 'Continue with Google' : 'Sign up with Google',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.black87 : const Color(0xFF1A1B21),
                      fontSize: 16,
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
