import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/model_progress.dart';
import '../../models/origami_model.dart';
import '../../providers/bookmark_provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/main_bottom_nav_bar.dart';
import '../model_details/model_details_screen.dart';

/// Bookmark screen (`/home/bookmark`).
///
/// Backed by [BookmarkProvider] (`GET /api/bookmarks/favorites` and
/// `/api/bookmarks/in-progress`, `Backend/Controllers/BookmarksController.cs`):
/// a segmented control switches between two lists per the spec (README §5):
/// **Favorites** (saved models) and **In Progress** (models mid-fold, showing
/// the resume step, a progress bar, and the last session date). Visual
/// design (colors, type, spacing, shape) is unchanged from the Figma export.
class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final bookmarks = context.read<BookmarkProvider>();
    if (bookmarks.status == BookmarkLoadStatus.initial) {
      bookmarks.load();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookmarks = context.watch<BookmarkProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 384),
                child: _SegmentedTabBar(controller: _tabController),
              ),
            ),
            Expanded(
              child: _Body(
                bookmarks: bookmarks,
                tabController: _tabController,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNavBar(current: MainTab.bookmark),
    );
  }
}

/// Routes to a loading spinner, an error state with retry, or the tab
/// content, based on [BookmarkProvider.status].
class _Body extends StatelessWidget {
  const _Body({required this.bookmarks, required this.tabController});

  final BookmarkProvider bookmarks;
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    switch (bookmarks.status) {
      case BookmarkLoadStatus.initial:
      case BookmarkLoadStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case BookmarkLoadStatus.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                bookmarks.errorMessage ?? 'Could not load bookmarks.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF454652)),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => bookmarks.load(),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      case BookmarkLoadStatus.loaded:
        return TabBarView(
          controller: tabController,
          children: [
            _FavoritesList(models: bookmarks.favorites),
            _InProgressList(items: bookmarks.inProgress),
          ],
        );
    }
  }
}

/// Segmented control switching between "Favorites" and "In Progress".
class _SegmentedTabBar extends StatelessWidget {
  const _SegmentedTabBar({required this.controller});

  final TabController controller;

  static const _labels = ['Favorites', 'In Progress'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: ShapeDecoration(
        color: const Color(0xFFEFEDF6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Row(
            children: List.generate(_labels.length, (index) {
              final selected = controller.index == index;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => controller.animateTo(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: ShapeDecoration(
                      color: selected ? Colors.white : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      shadows: selected
                          ? const [
                              BoxShadow(
                                color: Color(0x0C000000),
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      _labels[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selected
                            ? const Color(0xFF011D86)
                            : const Color(0xFF454652),
                        fontSize: 14,
                        fontFamily: 'Work Sans',
                        fontWeight: FontWeight.w500,
                        height: 1.43,
                        letterSpacing: 0.10,
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF454652),
          fontSize: 14,
          fontFamily: 'Work Sans',
        ),
      ),
    );
  }
}

/// "Favorites" tab: saved models, swipe-to-remove.
class _FavoritesList extends StatelessWidget {
  const _FavoritesList({required this.models});

  final List<OrigamiModel> models;

  @override
  Widget build(BuildContext context) {
    if (models.isEmpty) {
      return const _EmptyState(message: 'No favorites yet.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: models.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final model = models[index];
        return Dismissible(
          key: ValueKey('favorite-${model.id}'),
          direction: DismissDirection.endToStart,
          background: const _RemoveBackground(),
          onDismissed: (_) =>
              context.read<BookmarkProvider>().toggleFavorite(model),
          child: _BookmarkCard(model: model),
        );
      },
    );
  }
}

/// "In Progress" tab: models mid-fold, with a resume progress bar.
class _InProgressList extends StatelessWidget {
  const _InProgressList({required this.items});

  final List<ModelProgress> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyState(message: 'Nothing in progress yet.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = items[index];
        return Dismissible(
          key: ValueKey('progress-${item.model.id}'),
          direction: DismissDirection.endToStart,
          background: const _RemoveBackground(),
          onDismissed: (_) =>
              context.read<BookmarkProvider>().removeProgress(item.model),
          child: _BookmarkCard(model: item.model, progress: item),
        );
      },
    );
  }
}

class _RemoveBackground extends StatelessWidget {
  const _RemoveBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: ShapeDecoration(
        color: const Color(0xFFBA1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Icon(Icons.delete_outline, color: Colors.white),
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  const _BookmarkCard({required this.model, this.progress});

  final OrigamiModel model;
  final ModelProgress? progress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ModelDetailsScreen(
            model: model,
            resumeStep: progress?.currentStep,
          ),
        ),
      ),
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFFF8F9FA),
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0x4CC5C5D4)),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHero(model: model),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    model.name,
                    style: const TextStyle(
                      color: Color(0xFF011D86),
                      fontSize: 16,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                  Row(
                    spacing: 16,
                    children: [
                      _MetaChip(
                        icon: Icons.timer_outlined,
                        label: '${model.estimatedMinutes} min',
                      ),
                      _MetaChip(
                        icon: Icons.layers_outlined,
                        label: '${model.steps.length} folds',
                      ),
                    ],
                  ),
                  if (progress != null) ...[
                    const SizedBox(height: 8),
                    _ProgressSection(item: progress!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardHero extends StatelessWidget {
  const _CardHero({required this.model});

  final OrigamiModel model;

  @override
  Widget build(BuildContext context) {
    final colors = _difficultyColors(model.difficulty);
    return SizedBox(
      width: double.infinity,
      height: 192,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: const Color(0xFFEFEDF6),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    model.heroUrl.isNotEmpty ? model.heroUrl : model.thumbnail,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: ShapeDecoration(
                color: Colors.white.withValues(alpha: 0.90),
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
              child: const Icon(
                Icons.favorite,
                size: 16,
                color: Color(0xFF011D86),
              ),
            ),
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: ShapeDecoration(
                color: colors.bg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                model.difficulty.label.toUpperCase(),
                style: TextStyle(
                  color: colors.fg,
                  fontSize: 10,
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w700,
                  height: 1.50,
                  letterSpacing: 0.50,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

({Color bg, Color fg}) _difficultyColors(Difficulty difficulty) {
  return switch (difficulty) {
    Difficulty.easy => (bg: const Color(0xFF795901), fg: Colors.white),
    Difficulty.medium => (bg: const Color(0xB2011D86), fg: Colors.white),
    Difficulty.hard => (bg: const Color(0xE5011D86), fg: Colors.white),
  };
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF454652)),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF454652),
            fontSize: 11,
            fontFamily: 'Work Sans',
            fontWeight: FontWeight.w500,
            height: 1.45,
            letterSpacing: 0.50,
          ),
        ),
      ],
    );
  }
}

/// "Step X of Y" + percentage progress bar + "Last folded" caption,
/// rendered on each In Progress card (README §5: "step metrics … percentage
/// bars, and a 'Last folded' timestamp").
class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.item});

  final ModelProgress item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step ${item.currentStep} of ${item.totalSteps}',
              style: const TextStyle(
                color: Color(0xFF011D86),
                fontSize: 12,
                fontFamily: 'Work Sans',
                fontWeight: FontWeight.w600,
                letterSpacing: 0.10,
              ),
            ),
            Text(
              '${item.currentStep}/${item.totalSteps}',
              style: const TextStyle(
                color: Color(0xFF454652),
                fontSize: 12,
                fontFamily: 'Work Sans',
                fontWeight: FontWeight.w500,
                letterSpacing: 0.10,
              ),
            ),
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(9999),
          child: LinearProgressIndicator(
            value: item.progress,
            minHeight: 8,
            backgroundColor: const Color(0xFFEFEDF6),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFDC003)),
          ),
        ),
        Text(
          _lastFoldedLabel(item.lastSessionDate),
          style: const TextStyle(
            color: Color(0xFF454652),
            fontSize: 11,
            fontFamily: 'Work Sans',
            fontWeight: FontWeight.w500,
            height: 1.45,
            letterSpacing: 0.50,
          ),
        ),
      ],
    );
  }
}

String _lastFoldedLabel(DateTime lastSession) {
  final days = DateTime.now().difference(lastSession).inDays;
  if (days <= 0) return 'Last folded today';
  if (days == 1) return 'Last folded yesterday';
  return 'Last folded $days days ago';
}
