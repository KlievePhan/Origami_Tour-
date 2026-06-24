import 'package:flutter/material.dart';

import '../../models/origami_model.dart';
import '../../widgets/app_header.dart';
import '../../widgets/main_bottom_nav_bar.dart';
import '../model_details/model_details_screen.dart';

/// Main menu / home shell screen (`/home`).
///
/// UI ported from the Figma export; restructured into a real screen widget
/// with a working header (avatar account menu + notifications), content
/// cards, and a bottom navigation bar linking to the Collection, Bookmark and
/// Profile screens (CLAUDE.md §8). Visual design (colors, type, spacing,
/// shape) is preserved from the Figma export.
class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: const [
                  _FeaturedMasterpieceCard(),
                  SizedBox(height: 16),
                  _ContinueSection(),
                  SizedBox(height: 16),
                  _RecommendedLessonCard(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNavBar(current: MainTab.collection),
    );
  }
}

/// Hero card promoting the featured model ("The Golden Dragon").
class _FeaturedMasterpieceCard extends StatelessWidget {
  const _FeaturedMasterpieceCard();

  static final _model = OrigamiModel.placeholder(
    id: 'golden-dragon',
    name: 'The Golden Dragon',
    thumbnail: 'https://placehold.co/334x188.png',
    difficulty: Difficulty.hard,
    estimatedMinutes: 90,
    totalSteps: 25,
    description:
        'A complex 150-fold structure using premium washi paper and gold '
        'leaf accents.',
    category: 'Featured',
  );

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ModelDetailsScreen(model: _model)),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x19011D86),
              blurRadius: 6,
              offset: Offset(0, 4),
              spreadRadius: -1,
            ),
            BoxShadow(
              color: Color(0x0F011D86),
              blurRadius: 4,
              offset: Offset(0, 2),
              spreadRadius: -1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            const Text(
              'FEATURED MASTERPIECE',
              style: TextStyle(
                color: Color(0xFF011D86),
                fontSize: 11,
                fontFamily: 'Work Sans',
                fontWeight: FontWeight.w500,
                height: 1.45,
                letterSpacing: 0.55,
              ),
            ),
            const Text(
              'The Golden Dragon',
              style: TextStyle(
                color: Color(0xFF24389C),
                fontSize: 28,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w600,
                height: 1.29,
              ),
            ),
            const Text(
              'A complex 150-fold structure using premium washi paper and gold leaf accents.',
              style: TextStyle(
                color: Color(0xFF454652),
                fontSize: 14,
                fontFamily: 'Work Sans',
                fontWeight: FontWeight.w400,
                height: 1.43,
                letterSpacing: 0.25,
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                height: 188,
                color: const Color(0xFFEFEDF6),
                child: Image.network(
                  'https://placehold.co/334x188.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Continue where you left off" two-column row of in-progress models.
class _ContinueSection extends StatelessWidget {
  const _ContinueSection();

  @override
  Widget build(BuildContext context) {
    return const Row(
      spacing: 12,
      children: [
        Expanded(
          child: _ContinueCard(
            imageUrl: 'https://placehold.co/149x149.png',
            levelLabel: 'Level 1',
            levelBackground: Color(0xCC011D86),
            levelForeground: Colors.white,
            title: 'Classic Crane',
            subtitle: '12 Folds · Complete',
          ),
        ),
        Expanded(
          child: _ContinueCard(
            imageUrl: 'https://placehold.co/149x149.png',
            levelLabel: 'Level 3',
            levelBackground: Color(0xFFFDD274),
            levelForeground: Color(0xFF775800),
            title: 'Tessellation',
            subtitle: '42 Folds · In Progress',
          ),
        ),
      ],
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.imageUrl,
    required this.levelLabel,
    required this.levelBackground,
    required this.levelForeground,
    required this.title,
    required this.subtitle,
  });

  final String imageUrl;
  final String levelLabel;
  final Color levelBackground;
  final Color levelForeground;
  final String title;
  final String subtitle;

  /// Builds an [OrigamiModel] for the Model Details screen from this card's
  /// display data (placeholder steps; see CLAUDE.md §6).
  OrigamiModel _toOrigamiModel(int totalSteps) {
    final levelNumber =
        int.tryParse(levelLabel.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
    final difficulty = switch (levelNumber) {
      <= 1 => Difficulty.easy,
      2 => Difficulty.medium,
      _ => Difficulty.hard,
    };
    return OrigamiModel.placeholder(
      id: title,
      name: title,
      thumbnail: imageUrl,
      difficulty: difficulty,
      estimatedMinutes: totalSteps,
      totalSteps: totalSteps,
      description: 'Pick up where you left off and continue folding $title.',
      category: 'Continue',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isInProgress = subtitle.contains('In Progress');
    final totalSteps =
        int.tryParse(subtitle.replaceAll(RegExp(r'[^0-9]'), '')) ?? 12;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ModelDetailsScreen(
            model: _toOrigamiModel(totalSteps),
            resumeStep: isInProgress ? (totalSteps / 2).round() : null,
          ),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          color: const Color(0xFFF4F2FC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x19011D86),
              blurRadius: 6,
              offset: Offset(0, 4),
              spreadRadius: -1,
            ),
            BoxShadow(
              color: Color(0x0F011D86),
              blurRadius: 4,
              offset: Offset(0, 2),
              spreadRadius: -1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(imageUrl, fit: BoxFit.cover),
                  ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: ShapeDecoration(
                        color: levelBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        levelLabel,
                        style: TextStyle(
                          color: levelForeground,
                          fontSize: 10,
                          fontFamily: 'Work Sans',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF011D86),
                fontSize: 16,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF454652),
                fontSize: 16,
                fontFamily: 'Work Sans',
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Recommended Lesson" card promoting a masterclass.
class _RecommendedLessonCard extends StatelessWidget {
  const _RecommendedLessonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFC5C5D4)),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        spacing: 16,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: ShapeDecoration(
              color: const Color(0x3324389C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            child: const Icon(
              Icons.water_drop_outlined,
              color: Color(0xFF24389C),
            ),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  'Masterclass: Wet Folding',
                  style: TextStyle(
                    color: Color(0xFF011D86),
                    fontSize: 16,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
                Text(
                  'Learn advanced textures with Indigo dye.',
                  style: TextStyle(
                    color: Color(0xFF454652),
                    fontSize: 12,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF757684)),
        ],
      ),
    );
  }
}
