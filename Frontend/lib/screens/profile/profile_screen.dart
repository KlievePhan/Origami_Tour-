import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/leveling_utils.dart';
import '../../widgets/app_header.dart';
import '../../widgets/main_bottom_nav_bar.dart';
import '../../widgets/user_avatar.dart';

/// Profile & achievements screen (`/home/profile`).
///
/// UI ported from the Figma export; restructured into a real screen widget
/// with a working header (avatar account menu + notifications), profile
/// summary, mastery progress, stats and achievement gallery, plus the shared
/// bottom navigation bar with "Profile" highlighted (CLAUDE.md §8). Visual
/// design (colors, type, spacing, shape) is preserved from the Figma export.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: const [
                  _ProfileSummaryCard(),
                  SizedBox(height: 16),
                  _MasteryCard(),
                  SizedBox(height: 16),
                  _StatsRow(),
                  SizedBox(height: 24),
                  _AchievementGallery(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNavBar(current: MainTab.profile),
    );
  }
}

/// Profile summary: avatar, mastery title, bio and earned-title badges.
class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: ShapeDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: isDark ? const Color(0xFF333333) : const Color(0x4CC5C5D4)),
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        spacing: 12,
        children: [
          _ProfileAvatarStack(avatarUrl: user?.avatarUrl),
          Text(
            user?.displayName ?? 'Guest',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? const Color(0xFFBAC3FF) : const Color(0xFF011D86),
              fontSize: 22,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w600,
              height: 1.27,
            ),
          ),
          Text(
            '${LevelingUtils.getRankTitle(user?.level ?? 1)} · Lv.${user?.level ?? 1}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF454652),
              fontSize: 14,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w500,
              height: 1.43,
              letterSpacing: 0.25,
            ),
          ),
          Text(
            'Journey of a thousand folds begins with a single crease.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF454652),
              fontSize: 14,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w400,
              height: 1.43,
              letterSpacing: 0.25,
            ),
          ),
          const Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              _TitleBadge(
                label: 'Pro Folder',
                background: Color(0xFF24389C),
                foreground: Colors.white,
              ),
              _TitleBadge(
                label: 'Zen Focus',
                background: Color(0xFFFDD274),
                foreground: Color(0xFF775800),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Decorative "paper-on-paper" avatar: two overlapping rotated squares with
/// the user's photo on top, evoking folded origami sheets.
class _ProfileAvatarStack extends StatelessWidget {
  const _ProfileAvatarStack({this.avatarUrl});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 104,
      height: 104,
      child: Stack(
        children: [
          Positioned(
            left: 6,
            top: 0,
            child: Transform.rotate(
              angle: 0.05,
              child: Container(
                width: 96,
                height: 96,
                decoration: ShapeDecoration(
                  color: const Color(0xFFFDD274),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 6,
            child: Transform.rotate(
              angle: -0.05,
              child: Container(
                width: 96,
                height: 96,
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: const Color(0xFF24389C),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 2, color: Colors.white),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: UserAvatar(avatarUrl: avatarUrl, size: 92),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small pill used for earned profile titles ("Pro Folder", "Zen Focus").
class _TitleBadge extends StatelessWidget {
  const _TitleBadge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: ShapeDecoration(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontFamily: 'Work Sans',
          fontWeight: FontWeight.w500,
          height: 1.45,
          letterSpacing: 0.50,
        ),
      ),
    );
  }
}

/// EXP progress card showing current mastery level and progress to the next
/// rank.
class _MasteryCard extends StatelessWidget {
  const _MasteryCard();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final exp = user?.exp ?? 0;
    final level = user?.level ?? 1;
    final expForNextRank = LevelingUtils.getExpForNextLevel(level);
    final expRemaining = expForNextRank - exp;
    
    final rankTitle = LevelingUtils.getRankTitle(level);
    final nextLevel = level + 1;
    final nextRankTitle = LevelingUtils.getRankTitle(nextLevel);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: ShapeDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF4F2FC),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: isDark ? const Color(0xFF333333) : const Color(0x33C5C5D4)),
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mastery',
                    style: TextStyle(
                      color: isDark ? const Color(0xFFBAC3FF) : const Color(0xFF011D86),
                      fontSize: 22,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      height: 1.27,
                    ),
                  ),
                  Text(
                    'Level $level $rankTitle',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF454652),
                      fontSize: 11,
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                      letterSpacing: 0.50,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 4,
                children: [
                  Text(
                    '$exp',
                    style: TextStyle(
                      color: isDark ? const Color(0xFFBAC3FF) : const Color(0xFF24389C),
                      fontSize: 22,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      height: 1.27,
                    ),
                  ),
                  Text(
                    '/ $expForNextRank EXP',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF454652),
                      fontSize: 14,
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                      letterSpacing: 0.25,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _ExpProgressBar(progress: expForNextRank == 0 ? 0 : exp / expForNextRank),
          Text(
            '$expRemaining EXP more to unlock "$nextRankTitle" rank',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF454652),
              fontSize: 11,
              fontStyle: FontStyle.italic,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w500,
              height: 1.45,
              letterSpacing: 0.50,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pill-shaped progress bar with crease tick marks, indicating EXP progress
/// toward the next mastery rank.
class _ExpProgressBar extends StatelessWidget {
  const _ExpProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 24,
      child: Stack(
        children: [
          Container(
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1, color: isDark ? const Color(0xFF333333) : const Color(0x4CC5C5D4)),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9999),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(color: isDark ? const Color(0xFFBAC3FF) : const Color(0xFF24389C)),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  4,
                  (_) => Container(width: 1, color: isDark ? const Color(0x66333333) : const Color(0x33C5C5D4)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Two-column row of headline stats ("Total Models", "Streak").
class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    
    return Row(
      spacing: 16,
      children: [
        Expanded(
          child: _StatCard(label: 'Total Models', value: '${user?.totalCompleted ?? 0}'),
        ),
        const Expanded(
          child: _StatCard(label: 'Streak', value: '5 Days'),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: isDark ? const Color(0xFF333333) : const Color(0x33C5C5D4)),
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF454652),
              fontSize: 11,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w500,
              height: 1.45,
              letterSpacing: 0.50,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isDark ? const Color(0xFFBAC3FF) : const Color(0xFF011D86),
              fontSize: 28,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w600,
              height: 1.29,
            ),
          ),
        ],
      ),
    );
  }
}

/// Grid of earned and locked achievements.
class _AchievementGallery extends StatelessWidget {
  const _AchievementGallery();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().currentUser;
    final level = user?.level ?? 1;
    final totalCompleted = user?.totalCompleted ?? 0;

    final achievements = [
      _Achievement(
        label: 'First Fold',
        icon: Icons.auto_awesome,
        background: const Color(0xFFB0EFE2),
        unlocked: totalCompleted > 0,
      ),
      _Achievement(
        label: 'Senior Apprentice',
        icon: Icons.military_tech,
        background: const Color(0xFFDEE0FF),
        unlocked: level >= 4,
      ),
      _Achievement(
        label: 'Master of Origami',
        icon: Icons.emoji_events,
        background: const Color(0xFFFFDF9E),
        unlocked: level >= 6,
      ),
      // Category completion achievement (currently static as backend doesn't track it yet)
      const _Achievement(
        label: 'Guru of Animal origami',
        icon: Icons.pets,
        background: Colors.white,
        unlocked: false,
      ),
      const _Achievement(
        label: '30 Day Streak',
        icon: Icons.local_fire_department_outlined,
        background: Colors.white,
        unlocked: false,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Achievement Gallery',
              style: TextStyle(
                color: isDark ? const Color(0xFFBAC3FF) : const Color(0xFF011D86),
                fontSize: 22,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w700,
                height: 1.27,
              ),
            ),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text('Achievement gallery is not wired up yet.'),
                    ),
                  );
              },
              child: Text(
                'View All',
                style: TextStyle(
                  color: isDark ? const Color(0xFFBAC3FF) : const Color(0xFF24389C),
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
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: achievements.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.sizeOf(context).width > 600 ? 6 : 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 8,
            mainAxisExtent: 132,
          ),
          itemBuilder: (context, index) =>
              _AchievementBadge(achievement: achievements[index]),
        ),
      ],
    );
  }
}

class _Achievement {
  const _Achievement({
    required this.label,
    required this.icon,
    required this.background,
    required this.unlocked,
  });

  final String label;
  final IconData icon;
  final Color background;
  final bool unlocked;
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({required this.achievement});

  final _Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: ShapeDecoration(
            color: achievement.unlocked ? achievement.background : (isDark ? const Color(0xFF333333) : achievement.background),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 4,
                color: achievement.unlocked
                    ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
                    : (isDark ? const Color(0xFF454652) : const Color(0xFFC5C5D4)),
              ),
              borderRadius: BorderRadius.circular(9999),
            ),
            shadows: achievement.unlocked
                ? const [
                    BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                      spreadRadius: -2,
                    ),
                    BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 6,
                      offset: Offset(0, 4),
                      spreadRadius: -1,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            achievement.icon,
            color: achievement.unlocked
                ? const Color(0xFF1A1B21)
                : (isDark ? Colors.white70 : const Color(0xFF757684)),
          ),
        ),
        Text(
          achievement.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: achievement.unlocked
                ? (isDark ? Colors.white : const Color(0xFF1A1B21))
                : (isDark ? Colors.white70 : const Color(0xFF454652)),
            fontSize: 11,
            fontFamily: 'Work Sans',
            fontWeight: FontWeight.w500,
            height: 1.45,
            letterSpacing: 0.50,
          ),
        ),
      ],
    );

    return achievement.unlocked
        ? content
        : Opacity(opacity: 0.50, child: content);
  }
}
