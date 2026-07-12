import 'package:flutter/material.dart';

import '../../utils/leveling_utils.dart';
import '../profile/profile_screen.dart';

/// Finish screen (`/finish`).
///
/// UI ported from the Figma export; restructured into a real screen widget.
/// Per README §9 / CLAUDE.md §9-D, this screen presents the result of a
/// completed folding session: elapsed time, EXP earned, the unlocked
/// achievement, mastery progress toward the next rank, and recently earned
/// badges, finishing with "Back to Home" / "View Profile" actions. The
/// screen is not dismissible by back gesture. Visual design (colors, type,
/// spacing, shape) is unchanged.
class FinishScreen extends StatelessWidget {
  const FinishScreen({
    super.key,
    this.modelTitle,
    this.modelThumbnailUrl,
    required this.expGained,
    required this.currentExp,
    required this.elapsedSeconds,
  });

  /// Title of the model that was just completed. Falls back to the
  /// placeholder session result's title when not provided.
  final String? modelTitle;

  /// Thumbnail of the model that was just completed, shown in the
  /// "Refined Precision" achievement showcase. Falls back to the
  /// placeholder session result's image when not provided.
  final String? modelThumbnailUrl;

  final int expGained;
  final int currentExp;
  final int elapsedSeconds;

  /// Pops this screen and the Model Details screen beneath it, returning to
  /// whichever Collection/Bookmark/Home screen the tutorial was started from.
  void _handleBackToHome(BuildContext context) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.pop();
  }

  /// Returns to the originating screen (as above) and opens the Profile tab.
  void _handleViewProfile(BuildContext context) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.pop();
    navigator.push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final title = modelTitle ?? 'Traditional Crane';
    final String elapsedTimeFormatted = '${(elapsedSeconds ~/ 60).toString().padLeft(2, '0')}:${(elapsedSeconds % 60).toString().padLeft(2, '0')}';
    
    final level = LevelingUtils.getLevel(currentExp);
    final nextLevel = level + 1;
    final expForNextLevel = LevelingUtils.getExpForNextLevel(level);
    final rankTitle = '${LevelingUtils.getRankTitle(level)} · Lv.$level';
    final nextRankTitle = 'Next: ${LevelingUtils.getRankTitle(nextLevel)} (Lv. $nextLevel)';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        body: Stack(
          children: [
            const _BackgroundDecoration(),
            SafeArea(
              child: Column(
                children: [
                  _Header(rankTitle: rankTitle),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 160),
                      children: [
                        _MasteryBanner(modelTitle: title),
                        const SizedBox(height: 24),
                        _StatsRow(
                          elapsedTime: elapsedTimeFormatted,
                          expGained: expGained,
                        ),
                        const SizedBox(height: 24),
                        _AchievementShowcase(
                          name: 'Refined Precision',
                          imageUrl:
                              modelThumbnailUrl ?? 'https://placehold.co/350x350.png',
                        ),
                        const SizedBox(height: 24),
                        _MasteryProgressCard(
                          rankTitle: rankTitle,
                          nextRankTitle: nextRankTitle,
                          currentExp: currentExp,
                          expForNextLevel: expForNextLevel,
                        ),
                        const SizedBox(height: 24),
                        const _AchievementBadgesRow(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _BottomActions(
              onBackToHome: () => _handleBackToHome(context),
              onViewProfile: () => _handleViewProfile(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Soft celebratory blobs + confetti squares behind the content.
class _BackgroundDecoration extends StatelessWidget {
  const _BackgroundDecoration();

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -60,
              left: 39,
              child: _Blob(size: 256, color: Color(0x19FDC003)),
            ),
            Positioned(
              bottom: -120,
              left: -40,
              child: _Blob(size: 320, color: Color(0x0C24389C)),
            ),
            Positioned(top: 96, right: 56, child: _ConfettiSquare(angle: 0.28)),
            Positioned(
              top: 168,
              left: 48,
              child: _ConfettiSquare(angle: -0.40),
            ),
            Positioned(
              top: 248,
              right: 120,
              child: _ConfettiSquare(angle: 0.60),
            ),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
    );
  }
}

class _ConfettiSquare extends StatelessWidget {
  const _ConfettiSquare({required this.angle});

  final double angle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: 9,
        height: 9,
        decoration: ShapeDecoration(
          color: const Color(0x33FDC003),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        ),
      ),
    );
  }
}

/// Top app bar: mastery rank + avatar (README §3).
class _Header extends StatelessWidget {
  const _Header({required this.rankTitle});
  
  final String rankTitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
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
          Text(
            rankTitle,
            style: TextStyle(
              color: isDark ? const Color(0xFFBAC3FF) : const Color(0xFF011D86),
              fontSize: 22,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w700,
              height: 1.27,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: isDark ? const Color(0xFF333333) : const Color(0xFFE9E7F0),
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 2, color: isDark ? const Color(0xFFBAC3FF) : const Color(0xFF24389C)),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            child: Icon(Icons.person, color: isDark ? const Color(0xFFBAC3FF) : const Color(0xFF24389C)),
          ),
        ],
      ),
    );
  }
}

/// Amber "MASTERY ACHIEVED" badge + model title + congratulatory subtitle.
class _MasteryBanner extends StatelessWidget {
  const _MasteryBanner({required this.modelTitle});

  final String modelTitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      spacing: 8,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: ShapeDecoration(
            color: const Color(0xFFFDC003),
            shape: RoundedRectangleBorder(
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
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              Icon(Icons.emoji_events, size: 16, color: Color(0xFF011D86)),
              Text(
                'MASTERY ACHIEVED',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF011D86),
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
        Text(
          modelTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? const Color(0xFFBAC3FF) : const Color(0xFF011D86),
            fontSize: 28,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w800,
            height: 1.29,
            letterSpacing: -0.70,
          ),
        ),
        Text(
          "You've mastered the cornerstone of\norigami.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? Colors.white70 : const Color(0xFF454652),
            fontSize: 16,
            fontFamily: 'Work Sans',
            fontWeight: FontWeight.w400,
            height: 1.50,
            letterSpacing: 0.50,
          ),
        ),
      ],
    );
  }
}

/// "TIME" + "EARNED" stat cards shown side by side.
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.elapsedTime, required this.expGained});

  final String elapsedTime;
  final int expGained;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      spacing: 16,
      children: [
        Expanded(
          child: _StatCard(
            label: 'TIME',
            value: elapsedTime,
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF4F2FC),
            borderColor: isDark ? const Color(0xFF333333) : const Color(0xFFC5C5D4),
            labelColor: isDark ? Colors.white70 : const Color(0xFF454652),
            valueColor: isDark ? const Color(0xFFBAC3FF) : const Color(0xFF011D86),
          ),
        ),
        Expanded(
          child: _StatCard(
            label: 'EARNED',
            value: '+$expGained\nEXP',
            backgroundColor: isDark ? const Color(0xFF4A3400) : const Color(0xFFFDD274),
            borderColor: const Color(0xFFFDC003),
            labelColor: isDark ? const Color(0xFFFDD274) : const Color(0xFF775800),
            valueColor: isDark ? const Color(0xFFFDD274) : const Color(0xFF775800),
            valueFontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.backgroundColor,
    required this.borderColor,
    required this.labelColor,
    required this.valueColor,
    this.valueFontWeight = FontWeight.w700,
  });

  final String label;
  final String value;
  final Color backgroundColor;
  final Color borderColor;
  final Color labelColor;
  final Color valueColor;
  final FontWeight valueFontWeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: borderColor),
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
        spacing: 4,
        children: [
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 11,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w500,
              height: 1.45,
              letterSpacing: 0.55,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 32,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: valueFontWeight,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

/// Large image card showcasing the achievement unlocked this session.
class _AchievementShowcase extends StatelessWidget {
  const _AchievementShowcase({required this.name, required this.imageUrl});

  final String name;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 350,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 4, color: isDark ? const Color(0xFF333333) : Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: const [
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
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(imageUrl, fit: BoxFit.cover),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.50, 1.00),
                end: Alignment(0.50, 0.00),
                colors: [Color(0x66011D86), Color(0x00011D86)],
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  height: 1.27,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Mastery Level X" card with a progress bar toward the next rank.
class _MasteryProgressCard extends StatelessWidget {
  const _MasteryProgressCard({
    required this.rankTitle,
    required this.nextRankTitle,
    required this.currentExp,
    required this.expForNextLevel,
  });

  final String rankTitle;
  final String nextRankTitle;
  final int currentExp;
  final int expForNextLevel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = expForNextLevel == 0 ? 0.0 : currentExp / expForNextLevel;
    final percent = (progress * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: ShapeDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFBF8FF),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: isDark ? const Color(0xFF333333) : const Color(0x1924389C)),
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 10,
            offset: Offset(0, 8),
            spreadRadius: -6,
          ),
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 25,
            offset: Offset(0, 20),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rankTitle,
                    style: TextStyle(
                      color: isDark ? const Color(0xFFBAC3FF) : const Color(0xFF011D86),
                      fontSize: 14,
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w700,
                      height: 1.43,
                      letterSpacing: 0.10,
                    ),
                  ),
                  Text(
                    nextRankTitle,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: ShapeDecoration(
                  color: isDark ? const Color(0x33BAC3FF) : const Color(0x1924389C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
                child: Text(
                  '$percent%',
                  style: TextStyle(
                    color: isDark ? const Color(0xFFBAC3FF) : const Color(0xFF011D86),
                    fontSize: 11,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                    letterSpacing: 0.50,
                  ),
                ),
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: Container(
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0x4C24389C),
                    blurRadius: 10,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 14,
                backgroundColor: const Color(0xFFE9E7F0),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF011D86),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_formatExp(currentExp)} EXP',
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
                '${_formatExp(expForNextLevel)} EXP',
                style: TextStyle(
                  color: isDark ? const Color(0xFFBAC3FF) : const Color(0xFF011D86),
                  fontSize: 11,
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                  letterSpacing: 0.50,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatExp(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

/// Row of recently-earned achievement badge icons.
class _AchievementBadgesRow extends StatelessWidget {
  const _AchievementBadgesRow();

  static const _icons = [
    Icons.military_tech,
    Icons.bolt,
    Icons.workspace_premium,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      spacing: 16,
      children: [
        for (final icon in _icons)
          Container(
            width: 48,
            height: 48,
            decoration: ShapeDecoration(
              color: isDark ? const Color(0x33BAC3FF) : const Color(0x1924389C),
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1, color: isDark ? const Color(0x33BAC3FF) : const Color(0x3324389C)),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            child: Icon(icon, color: isDark ? const Color(0xFFBAC3FF) : const Color(0xFF24389C)),
          ),
      ],
    );
  }
}

/// Sticky bottom action bar: "Back to Home" (outlined) and "View Profile"
/// (filled), faded in over the scrolling content.
class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.onBackToHome,
    required this.onViewProfile,
  });

  final VoidCallback onBackToHome;
  final VoidCallback onViewProfile;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryActionColor = isDark ? const Color(0xFFBAC3FF) : const Color(0xFF011D86);

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: const Alignment(0.50, 1.00),
            end: const Alignment(0.50, 0.00),
            colors: isDark 
                ? const [Color(0xFF121212), Color(0xFF121212), Color(0x00121212)]
                : const [Color(0xFFFBF8FF), Color(0xFFFBF8FF), Color(0x00FBF8FF)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            OutlinedButton.icon(
              onPressed: onBackToHome,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                side: BorderSide(width: 2, color: primaryActionColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(Icons.home_outlined, color: primaryActionColor),
              label: Text(
                'Back to Home',
                style: TextStyle(
                  color: primaryActionColor,
                  fontSize: 14,
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w700,
                  height: 1.43,
                  letterSpacing: 0.10,
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: onViewProfile,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: isDark ? Theme.of(context).colorScheme.primary : const Color(0xFF011D86),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shadowColor: const Color(0x19000000),
              ),
              icon: const Icon(Icons.person_outline, color: Colors.white),
              label: const Text(
                'View Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w700,
                  height: 1.43,
                  letterSpacing: 0.10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


