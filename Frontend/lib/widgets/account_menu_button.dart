import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';

/// Wraps an avatar with a dropdown menu offering "Settings" and "Logout"
/// (CLAUDE.md §8: tapping the avatar opens an account menu overlay).
/// UI only — logout shows a confirmation dialog and clears the navigation
/// stack back to [LoginScreen]; settings surfaces a placeholder snackbar.
class AccountMenuButton extends StatelessWidget {
  const AccountMenuButton({super.key, required this.avatar});

  final Widget avatar;

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _openSettings(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Settings is not wired up yet.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Account menu',
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'settings') {
          _openSettings(context);
        } else if (value == 'logout') {
          _confirmLogout(context);
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'settings',
          child: ListTile(
            leading: Icon(Icons.settings_outlined, color: Color(0xFF454652)),
            title: Text('Settings'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: ListTile(
            leading: Icon(Icons.logout, color: Color(0xFFBA1A1A)),
            title: Text('Logout', style: TextStyle(color: Color(0xFFBA1A1A))),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
      child: avatar,
    );
  }
}
