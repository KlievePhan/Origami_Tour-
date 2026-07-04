import 'package:flutter/material.dart';

/// Circular avatar for the signed-in user.
///
/// Shows [avatarUrl] when the user has one; otherwise falls back to a simple
/// default person icon, so the header/profile screens never depend on an
/// external placeholder image just to render "no avatar yet".
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, this.avatarUrl, this.size = 40});

  final String? avatarUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: const Color(0xFFDEE0FF),
      backgroundImage: hasAvatar ? NetworkImage(avatarUrl!) : null,
      child: hasAvatar
          ? null
          : Icon(
              Icons.person,
              color: const Color(0xFF24389C),
              size: size * 0.6,
            ),
    );
  }
}
