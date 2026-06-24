import 'package:flutter/material.dart';

import '../../models/origami_model.dart';
import '../../widgets/app_header.dart';
import '../../widgets/main_bottom_nav_bar.dart';
import '../model_details/model_details_screen.dart';

/// Bookmark screen (`/home/bookmark`).
///
/// UI ported from the Figma export; restructured into a real screen widget
/// with a working segmented control that switches between two lists per the
/// spec (README §5): **Favorites** (saved models) and **In Progress**
/// (models mid-fold, showing the resume step, a progress bar, and the last
/// session date). Visual design (colors, type, spacing, shape) is unchanged.
class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // TODO(agent): replace with BookmarkProvider.favorites / .inProgress
  // (prov-bookmark is not_started yet).
  static final List<_BookmarkItem> _favorites = [
    const _BookmarkItem(
      title: 'Celestial Dragon',
      imageUrl: 'https://placehold.co/356x192.png',
      difficultyLabel: 'EXPERT',
      difficultyColor: Color(0xE5011D86),
      estimatedTime: '45 min',
      foldsLabel: '64 folds',
    ),
    const _BookmarkItem(
      title: 'Monarch Flutter',
      imageUrl: 'https://placehold.co/356x192.png',
      difficultyLabel: 'BEGINNER',
      difficultyColor: Color(0xFF795901),
      estimatedTime: '12 min',
      foldsLabel: '18 folds',
    ),
    const _BookmarkItem(
      title: 'Sacred Lotus',
      imageUrl: 'https://placehold.co/356x192.png',
      difficultyLabel: 'INTERMEDIATE',
      difficultyColor: Color(0xB2011D86),
      estimatedTime: '25 min',
      foldsLabel: '32 folds',
    ),
  ];

  static final List<_InProgressItem> _inProgress = [
    const _InProgressItem(
      title: 'Celestial Dragon',
      imageUrl: 'https://placehold.co/356x192.png',
      difficultyLabel: 'EXPERT',
      difficultyColor: Color(0xE5011D86),
      estimatedTime: '45 min',
      foldsLabel: '64 folds',
      currentStep: 7,
      totalSteps: 15,
      lastFolded: 'Last folded 2 days ago',
    ),
    const _InProgressItem(
      title: 'Monarch Flutter',
      imageUrl: 'https://placehold.co/356x192.png',
      difficultyLabel: 'BEGINNER',
      difficultyColor: Color(0xFF795901),
      estimatedTime: '12 min',
      foldsLabel: '18 folds',
      currentStep: 3,
      totalSteps: 8,
      lastFolded: 'Last folded yesterday',
    ),
    const _InProgressItem(
      title: 'Sacred Lotus',
      imageUrl: 'https://placehold.co/356x192.png',
      difficultyLabel: 'INTERMEDIATE',
      difficultyColor: Color(0xB2011D86),
      estimatedTime: '25 min',
      foldsLabel: '32 folds',
      currentStep: 10,
      totalSteps: 12,
      lastFolded: 'Last folded today',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              child: TabBarView(
                controller: _tabController,
                children: [
                  _BookmarkList(items: _favorites),
                  _BookmarkList(items: _inProgress),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNavBar(current: MainTab.bookmark),
    );
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

/// Scrollable list of bookmark cards shared by both tabs. When [items]
/// contains [_InProgressItem]s, each card additionally renders a progress
/// bar and "Step X of Y" / "last folded" metadata.
class _BookmarkList extends StatelessWidget {
  const _BookmarkList({required this.items});

  final List<_BookmarkItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Nothing here yet',
          style: TextStyle(
            color: Color(0xFF454652),
            fontSize: 14,
            fontFamily: 'Work Sans',
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _BookmarkCard(item: items[index]),
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  const _BookmarkCard({required this.item});

  final _BookmarkItem item;

  @override
  Widget build(BuildContext context) {
    final inProgress = item is _InProgressItem ? item as _InProgressItem : null;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ModelDetailsScreen(
            model: item.toOrigamiModel(),
            resumeStep: inProgress?.currentStep,
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
            _CardHero(item: item),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    item.title,
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
                        label: item.estimatedTime,
                      ),
                      _MetaChip(
                        icon: Icons.layers_outlined,
                        label: item.foldsLabel,
                      ),
                    ],
                  ),
                  if (inProgress != null) ...[
                    const SizedBox(height: 8),
                    _ProgressSection(item: inProgress),
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
  const _CardHero({required this.item});

  final _BookmarkItem item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 192,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(item.imageUrl),
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
                color: item.difficultyColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                item.difficultyLabel,
                style: const TextStyle(
                  color: Colors.white,
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

  final _InProgressItem item;

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
          item.lastFolded,
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

class _BookmarkItem {
  const _BookmarkItem({
    required this.title,
    required this.imageUrl,
    required this.difficultyLabel,
    required this.difficultyColor,
    required this.estimatedTime,
    required this.foldsLabel,
  });

  final String title;
  final String imageUrl;
  final String difficultyLabel;
  final Color difficultyColor;
  final String estimatedTime;
  final String foldsLabel;

  /// Builds an [OrigamiModel] for the Model Details / Process View screens
  /// from this card's display data (placeholder steps; see CLAUDE.md §6).
  OrigamiModel toOrigamiModel({int? totalStepsOverride}) {
    final difficulty = switch (difficultyLabel) {
      'BEGINNER' => Difficulty.easy,
      'INTERMEDIATE' => Difficulty.medium,
      'EXPERT' => Difficulty.hard,
      _ => Difficulty.medium,
    };
    final minutes =
        int.tryParse(estimatedTime.replaceAll(RegExp(r'[^0-9]'), '')) ?? 10;
    final steps =
        totalStepsOverride ??
        int.tryParse(foldsLabel.replaceAll(RegExp(r'[^0-9]'), '')) ??
        12;
    return OrigamiModel.placeholder(
      id: title,
      name: title,
      thumbnail: imageUrl,
      difficulty: difficulty,
      estimatedMinutes: minutes,
      totalSteps: steps,
      description:
          'A treasured fold from your bookmarks. Follow each step to '
          'recreate $title.',
      category: 'Bookmarked',
    );
  }
}

class _InProgressItem extends _BookmarkItem {
  const _InProgressItem({
    required super.title,
    required super.imageUrl,
    required super.difficultyLabel,
    required super.difficultyColor,
    required super.estimatedTime,
    required super.foldsLabel,
    required this.currentStep,
    required this.totalSteps,
    required this.lastFolded,
  });

  /// Resume point — the step the user last saved at (e.g. 7 of 15).
  final int currentStep;
  final int totalSteps;
  final String lastFolded;

  double get progress => totalSteps == 0 ? 0 : currentStep / totalSteps;

  @override
  OrigamiModel toOrigamiModel({int? totalStepsOverride}) {
    return super.toOrigamiModel(
      totalStepsOverride: totalStepsOverride ?? totalSteps,
    );
  }
}
