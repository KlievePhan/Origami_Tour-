import 'package:flutter/material.dart';

import 'account_menu_button.dart';

/// Persistent top app bar shown on every primary tab screen (Menu, Collection,
/// Bookmark, Profile): avatar account menu, display name, mastery-rank pill,
/// and a notifications action. Sits outside the scrollable body in each
/// screen's layout, so it stays fixed in place while content scrolls.
class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        boxShadow: [
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
            children: const [
              AccountMenuButton(avatar: _Avatar()),
              _NameAndRank(),
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
            icon: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF454652),
            ),
          ),
        ],
      ),
    );
  }
}

/// 40x40 avatar with an indigo border and an amber "online" status badge.
class _Avatar extends StatelessWidget {
  const _Avatar();

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
                side: const BorderSide(width: 2, color: Color(0xFF24389C)),
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
            child: Image.network(
              'https://placehold.co/36x36.png',
              fit: BoxFit.cover,
            ),
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
                  side: const BorderSide(width: 2, color: Color(0xFFF8F9FA)),
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
  const _NameAndRank();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        const Text(
          'Phan Anh',
          style: TextStyle(
            color: Color(0xFF011D86),
            fontSize: 22,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w500,
            height: 1.25,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: ShapeDecoration(
            color: const Color(0x1924389C),
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0x3324389C)),
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
          child: const Text(
            'Crane Apprentice · Lv.4',
            style: TextStyle(
              color: Color(0xFF283CA0),
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
