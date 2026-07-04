import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/origami_model.dart';
import '../../providers/bookmark_provider.dart';
import '../process_view/process_view_screen.dart';

/// Model Details screen (`/model/:id`).
///
/// Shows an overview of an [OrigamiModel] — hero image, difficulty/time/folds
/// stats, description, and rating — with a primary action that starts (or
/// resumes) the folding tutorial in [ProcessViewScreen] (CLAUDE.md §10,
/// screen #7). Step content for that tutorial comes from [model.steps],
/// which is placeholder data until CollectionProvider/BookmarkProvider exist
/// (CLAUDE.md §7).
class ModelDetailsScreen extends StatelessWidget {
  const ModelDetailsScreen({super.key, required this.model, this.resumeStep});

  final OrigamiModel model;

  /// If set (and greater than 1), the primary action becomes "Resume" and
  /// opens the tutorial at this step instead of step 1 — used for
  /// Collection/Bookmark "in progress" cards.
  final int? resumeStep;

  void _startFolding(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ProcessViewScreen(model: model, startStep: resumeStep ?? 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalSteps = model.steps.length;
    final inProgress = (resumeStep ?? 1) > 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(model: model),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  _HeroImage(
                    imageUrl: model.heroUrl.isNotEmpty
                        ? model.heroUrl
                        : model.thumbnail,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    model.name,
                    style: const TextStyle(
                      color: Color(0xFF24389C),
                      fontSize: 28,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w600,
                      height: 1.29,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _StatsRow(model: model, totalSteps: totalSteps),
                  const SizedBox(height: 16),
                  Text(
                    model.description,
                    style: const TextStyle(
                      color: Color(0xFF454652),
                      fontSize: 14,
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                      letterSpacing: 0.25,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _RatingCard(model: model),
                ],
              ),
            ),
            _BottomAction(
              label: inProgress
                  ? 'Resume — Step $resumeStep of $totalSteps'
                  : 'Start Folding',
              onPressed: () => _startFolding(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// App bar: back button, screen title, and a favorite toggle backed by
/// [BookmarkProvider].
class _Header extends StatelessWidget {
  const _Header({required this.model});

  final OrigamiModel model;

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.watch<BookmarkProvider>().isFavorite(model.id);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, color: Color(0xFF454652)),
            tooltip: 'Back',
          ),
          const Text(
            'Model Details',
            style: TextStyle(
              color: Color(0xFF011D86),
              fontSize: 18,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w700,
              height: 1.27,
            ),
          ),
          IconButton(
            onPressed: () =>
                context.read<BookmarkProvider>().toggleFavorite(model),
            icon: Icon(
              isFavorite ? Icons.bookmark : Icons.bookmark_add_outlined,
              color: const Color(0xFF24389C),
            ),
            tooltip: isFavorite ? 'Remove bookmark' : 'Bookmark',
          ),
        ],
      ),
    );
  }
}

/// Large rounded hero image for the model.
class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: const Color(0xFFEFEDF6),
          child: Image.network(imageUrl, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

/// Difficulty/time/folds/category chips summarizing the model.
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.model, required this.totalSteps});

  final OrigamiModel model;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final colors = _difficultyColors(model.difficulty);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StatChip(
          label: model.difficulty.label,
          icon: Icons.bar_chart,
          background: colors.bg,
          foreground: colors.fg,
        ),
        _StatChip(
          label: '${model.estimatedMinutes} min',
          icon: Icons.timer_outlined,
        ),
        _StatChip(label: '$totalSteps folds', icon: Icons.layers_outlined),
        _StatChip(label: model.category, icon: Icons.category_outlined),
      ],
    );
  }
}

({Color bg, Color fg}) _difficultyColors(Difficulty difficulty) {
  return switch (difficulty) {
    Difficulty.easy => (
      bg: const Color(0xFFDCFCE7),
      fg: const Color(0xFF166534),
    ),
    Difficulty.medium => (
      bg: const Color(0xFFFEF3C7),
      fg: const Color(0xFF92400E),
    ),
    Difficulty.hard => (
      bg: const Color(0xFFFEE2E2),
      fg: const Color(0xFF991B1B),
    ),
  };
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.icon,
    this.background = const Color(0xFFF4F2FC),
    this.foreground = const Color(0xFF454652),
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: ShapeDecoration(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Icon(icon, size: 14, color: foreground),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w600,
              letterSpacing: 0.10,
            ),
          ),
        ],
      ),
    );
  }
}

/// Rating + completion count card.
class _RatingCard extends StatelessWidget {
  const _RatingCard({required this.model});

  final OrigamiModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFC5C5D4)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: Color(0xFFFDC003)),
          const SizedBox(width: 8),
          Text(
            model.ratingAvg.toStringAsFixed(1),
            style: const TextStyle(
              color: Color(0xFF011D86),
              fontSize: 16,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w700,
              height: 1.50,
            ),
          ),
          Text(
            ' (${model.ratingCount} ratings)',
            style: const TextStyle(
              color: Color(0xFF454652),
              fontSize: 12,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
          ),
          const Spacer(),
          Text(
            '${model.completionCount} completions',
            style: const TextStyle(
              color: Color(0xFF454652),
              fontSize: 12,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sticky bottom "Start Folding" / "Resume" button.
class _BottomAction extends StatelessWidget {
  const _BottomAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: ShapeDecoration(
        color: const Color(0xFFF4F2FC),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0x19C5C5D4)),
        ),
      ),
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(64),
          backgroundColor: const Color(0xFF011D86),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: const Color(0x19000000),
        ),
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w500,
            height: 1.27,
          ),
        ),
      ),
    );
  }
}
