import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/leveling_utils.dart';
import 'account_menu_button.dart';
import 'user_avatar.dart';

/// Persistent top app bar shown on every primary tab screen (Menu, Collection,
/// Bookmark, Profile): avatar account menu, display name, mastery-rank pill,
/// and a notifications action. Sits outside the scrollable body in each
/// screen's layout, so it stays fixed in place while content scrolls.
class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F9FA),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: 12,
            children: [
              AccountMenuButton(avatar: _Avatar(avatarUrl: user?.avatarUrl, isDark: isDark)),
              _NameAndRank(user: user, isDark: isDark),
            ],
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('No new notifications.')),
                );
            },
            icon: Icon(
              Icons.notifications_outlined,
              color: isDark ? Colors.white : const Color(0xFF454652),
            ),
          ),
        ],
      ),
    );
  }
}

/// 40x40 avatar with an indigo border and an amber "online" status badge.
class _Avatar extends StatelessWidget {
  const _Avatar({this.avatarUrl, required this.isDark});

  final String? avatarUrl;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 2, color: Theme.of(context).colorScheme.primary),
                borderRadius: BorderRadius.circular(9999),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: UserAvatar(avatarUrl: avatarUrl, size: 36),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 16,
              height: 16,
              decoration: ShapeDecoration(
                color: const Color(0xFFFDC003),
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 2, color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F9FA)),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Display name and mastery-rank pill shown next to the avatar.
class _NameAndRank extends StatelessWidget {
  const _NameAndRank({required this.user, required this.isDark});

  final dynamic user;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(
          user?.displayName ?? 'Guest',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF011D86),
            fontSize: 22,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
            height: 1.27,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: ShapeDecoration(
            color: isDark ? Colors.white12 : const Color(0x1924389C),
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1, color: isDark ? Colors.white24 : const Color(0x3324389C)),
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
          child: Text(
            '${LevelingUtils.getRankTitle(user?.level ?? 1)} · Lv.${user?.level ?? 1}',
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF454652),
              fontSize: 11,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w500,
              height: 1.45,
              letterSpacing: 0.50,
            ),
          ),
        ),
      ],
    );
  }
}
