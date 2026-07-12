import 'package:flutter/material.dart';

import '../screens/bookmark/bookmark_screen.dart';
import '../screens/collection/collection_screen.dart';
import '../screens/profile/profile_screen.dart';

/// The three tabs of the main app shell (CLAUDE.md §8 route table:
/// `/home/collection`, `/home/bookmark`, `/home/profile`).
enum MainTab { collection, bookmark, profile }

/// Bottom navigation bar shared by the Menu shell and Profile screen, linking
/// to the Collection, Bookmark and Profile screens. [current] only controls
/// which item is highlighted — every item still navigates when tapped, since
/// each screen is pushed independently (go_router's StatefulShellRoute is not
/// yet implemented).
class MainBottomNavBar extends StatelessWidget {
  const MainBottomNavBar({super.key, required this.current});

  final MainTab current;

  void _open(BuildContext context, MainTab tab) {
    final Widget screen = switch (tab) {
      MainTab.collection => const CollectionScreen(),
      MainTab.bookmark => const BookmarkScreen(),
      MainTab.profile => const ProfileScreen(),
    };
    Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: ShapeDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF4F2FC),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 15,
            offset: Offset(0, 10),
            spreadRadius: -3,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavBarItem(
              icon: Icons.grid_view_rounded,
              label: 'Collection',
              selected: current == MainTab.collection,
              isDark: isDark,
              onTap: () => _open(context, MainTab.collection),
            ),
            _NavBarItem(
              icon: Icons.bookmark_outline,
              label: 'Bookmark',
              selected: current == MainTab.bookmark,
              isDark: isDark,
              onTap: () => _open(context, MainTab.bookmark),
            ),
            _NavBarItem(
              icon: Icons.person_outline,
              label: 'Profile',
              selected: current == MainTab.profile,
              isDark: isDark,
              onTap: () => _open(context, MainTab.profile),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: ShapeDecoration(
          color: selected ? const Color(0xFF24389C) : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 2,
          children: [
            Icon(
              icon,
              size: 20,
              color: selected
                  ? Colors.white
                  : (isDark ? Colors.white70 : const Color(0xFF454652)),
            ),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.white70 : const Color(0xFF454652)),
                fontSize: 14,
                fontFamily: 'Work Sans',
                fontWeight: FontWeight.w500,
                height: 1.43,
                letterSpacing: 0.10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
