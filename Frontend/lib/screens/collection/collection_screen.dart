import 'package:flutter/material.dart';

import '../../models/origami_model.dart';
import '../../widgets/app_header.dart';
import '../../widgets/main_bottom_nav_bar.dart';
import '../model_details/model_details_screen.dart';

/// Collection screen (`/home/collection`).
///
/// UI ported from the Figma export; restructured into a real screen widget
/// with a working search field, filter chips, an overall-progress banner, and
/// a model grid. Per the spec (README §4) each card now reflects the
/// viewer's relationship to that model:
///  - **completed** — "Completed … ago"
///  - **in progress** — current resume step ("Step X of Y") + a mini progress bar
///  - **locked** — models the user hasn't unlocked/accessed yet (dimmed, lock badge)
/// Visual design (colors, type, spacing, shape) is unchanged.
class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  final _searchController = TextEditingController();

  static const _difficulties = ['Easy', 'Medium', 'Hard'];
  static const _categories = ['Animals', 'Birds', 'Modular', 'Holiday'];

  String? _selectedDifficulty;
  String? _selectedCategory;

  // TODO(agent): replace with CollectionProvider.models + per-model
  // completion/progress overlay (prov-collection is not_started yet).
  static const _models = <_CollectionModel>[
    _CollectionModel(
      title: 'Traditional Crane',
      imageUrl: 'https://placehold.co/169x169',
      difficultyLabel: 'EASY',
      difficultyBg: Color(0xFFDCFCE7),
      difficultyFg: Color(0xFF166534),
      estimatedTime: '5m',
      status: _ModelStatus.completed,
      statusLabel: 'Completed 2d ago',
    ),
    _CollectionModel(
      title: 'Curious Fox',
      imageUrl: 'https://placehold.co/169x169',
      difficultyLabel: 'MEDIUM',
      difficultyBg: Color(0xFFFEF3C7),
      difficultyFg: Color(0xFF92400E),
      estimatedTime: '15m',
      status: _ModelStatus.completed,
      statusLabel: 'Completed 1w ago',
    ),
    _CollectionModel(
      title: 'Monarch Butterfly',
      imageUrl: 'https://placehold.co/169x169',
      difficultyLabel: 'EASY',
      difficultyBg: Color(0xFFDCFCE7),
      difficultyFg: Color(0xFF166534),
      estimatedTime: '8m',
      status: _ModelStatus.inProgress,
      currentStep: 7,
      totalSteps: 15,
    ),
    _CollectionModel(
      title: 'Imperial Dragon',
      imageUrl: 'https://placehold.co/169x169',
      difficultyLabel: 'HARD',
      difficultyBg: Color(0xFFFEE2E2),
      difficultyFg: Color(0xFF991B1B),
      estimatedTime: '45m',
      status: _ModelStatus.inProgress,
      currentStep: 3,
      totalSteps: 20,
    ),
    _CollectionModel(
      title: 'Celestial Phoenix',
      imageUrl: 'https://placehold.co/169x169',
      difficultyLabel: 'HARD',
      difficultyBg: Color(0xFFFEE2E2),
      difficultyFg: Color(0xFF991B1B),
      estimatedTime: '60m',
      status: _ModelStatus.locked,
      statusLabel: 'Finish 3 more Hard models to unlock',
    ),
    _CollectionModel(
      title: 'Sacred Lotus',
      imageUrl: 'https://placehold.co/169x169',
      difficultyLabel: 'MEDIUM',
      difficultyBg: Color(0xFFFEF3C7),
      difficultyFg: Color(0xFF92400E),
      estimatedTime: '25m',
      status: _ModelStatus.locked,
      statusLabel: 'Reach Lv.5 to unlock',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleDifficulty(String label) {
    setState(
      () => _selectedDifficulty = _selectedDifficulty == label ? null : label,
    );
  }

  void _toggleCategory(String label) {
    setState(
      () => _selectedCategory = _selectedCategory == label ? null : label,
    );
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
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  _SearchBar(controller: _searchController),
                  const SizedBox(height: 16),
                  _FilterChipsRow(
                    options: _difficulties,
                    selected: _selectedDifficulty,
                    onSelected: _toggleDifficulty,
                  ),
                  const SizedBox(height: 12),
                  _FilterChipsRow(
                    options: _categories,
                    selected: _selectedCategory,
                    onSelected: _toggleCategory,
                    pill: true,
                  ),
                  const SizedBox(height: 24),
                  const _OverallProgressCard(finished: 12, total: 48),
                  const SizedBox(height: 24),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _models.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.72,
                        ),
                    itemBuilder: (context, index) =>
                        _ModelGridCard(model: _models[index]),
                  ),
                  const SizedBox(height: 24),
                  const Opacity(
                    opacity: 0.40,
                    child: Center(
                      child: Text(
                        'Scroll to discover more models',
                        style: TextStyle(
                          color: Color(0xFF1A1B21),
                          fontSize: 16,
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
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNavBar(current: MainTab.collection),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFFF4F2FC),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFC5C5D4)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: Color(0xFF1A1B21),
          fontSize: 16,
          fontFamily: 'Work Sans',
          fontWeight: FontWeight.w400,
        ),
        decoration: const InputDecoration(
          hintText: 'Search models...',
          hintStyle: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 16,
            fontFamily: 'Work Sans',
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(Icons.search, color: Color(0xFF6B7280)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 13.5),
        ),
      ),
    );
  }
}

/// Shared row of selectable filter chips (difficulty or category).
class _FilterChipsRow extends StatelessWidget {
  const _FilterChipsRow({
    required this.options,
    required this.selected,
    required this.onSelected,
    this.pill = false,
  });

  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  /// Pill-shaped outline chips (categories) vs. filled/outline difficulty chips.
  final bool pill;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(options.length, (index) {
          final label = options[index];
          final isSelected = selected == label;
          return Padding(
            padding: EdgeInsets.only(
              right: index == options.length - 1 ? 0 : 8,
            ),
            child: GestureDetector(
              onTap: () => onSelected(label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: pill ? 6 : 8.5,
                ),
                decoration: ShapeDecoration(
                  color: isSelected
                      ? const Color(0xFF24389C)
                      : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      color: isSelected
                          ? Colors.transparent
                          : const Color(0xFFC5C5D4),
                    ),
                    borderRadius: BorderRadius.circular(pill ? 12 : 9999),
                  ),
                  shadows: isSelected
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
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF9DABFF)
                        : const Color(0xFF454652),
                    fontSize: 16,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// "Finished: X / Y" banner with a percentage progress bar and a level-up nudge.
class _OverallProgressCard extends StatelessWidget {
  const _OverallProgressCard({required this.finished, required this.total});

  final int finished;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : finished / total;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFF24389C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        children: [
          Positioned(
            right: -18,
            top: -16,
            child: Container(
              width: 96,
              height: 96,
              decoration: ShapeDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              const Text(
                'OVERALL PROGRESS',
                style: TextStyle(
                  color: Color(0xFFBAC3FF),
                  fontSize: 16,
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                  letterSpacing: 0.80,
                ),
              ),
              Text(
                'Finished: $finished / $total',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  height: 1.29,
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(9999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: Colors.white.withValues(alpha: 0.20),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFDC003),
                  ),
                ),
              ),
              Text(
                "Keep going! You're ${total - finished} models away from\nLv.5",
                style: const TextStyle(
                  color: Color(0xFFDEE0FF),
                  fontSize: 16,
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModelGridCard extends StatelessWidget {
  const _ModelGridCard({required this.model});

  final _CollectionModel model;

  void _handleTap(BuildContext context) {
    if (model.status == _ModelStatus.locked) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(model.statusLabel)));
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ModelDetailsScreen(
          model: model.toOrigamiModel(),
          resumeStep: model.status == _ModelStatus.inProgress
              ? model.currentStep
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locked = model.status == _ModelStatus.locked;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _handleTap(context),
      child: Container(
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFEDEEEF)),
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
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColorFiltered(
                    colorFilter: locked
                        ? const ColorFilter.mode(
                            Colors.black54,
                            BlendMode.saturation,
                          )
                        : const ColorFilter.mode(
                            Colors.transparent,
                            BlendMode.multiply,
                          ),
                    child: Opacity(
                      opacity: locked ? 0.45 : 1,
                      child: Image.network(model.imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: ShapeDecoration(
                        color: model.difficultyBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        model.difficultyLabel,
                        style: TextStyle(
                          color: model.difficultyFg,
                          fontSize: 10,
                          fontFamily: 'Work Sans',
                          fontWeight: FontWeight.w700,
                          height: 1.50,
                        ),
                      ),
                    ),
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
                        color: Colors.black.withValues(alpha: 0.40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 4,
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 12,
                            color: Colors.white,
                          ),
                          Text(
                            model.estimatedTime,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontFamily: 'Work Sans',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (locked)
                    const Positioned.fill(
                      child: Center(
                        child: Icon(Icons.lock, color: Colors.white, size: 28),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      model.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF011D86),
                        fontSize: 16,
                        fontFamily: 'Work Sans',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
                    ),
                    Expanded(child: _ModelStatusArea(model: model)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders the per-model status: a "Completed … ago" caption, an in-progress
/// step counter with a mini progress bar, or a locked hint — per the
/// Collection screen's "individual in-progress status bar" requirement
/// (README §4).
class _ModelStatusArea extends StatelessWidget {
  const _ModelStatusArea({required this.model});

  final _CollectionModel model;

  @override
  Widget build(BuildContext context) {
    switch (model.status) {
      case _ModelStatus.completed:
        return Align(
          alignment: Alignment.bottomLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              const Icon(
                Icons.check_circle,
                size: 14,
                color: Color(0xFF166534),
              ),
              Flexible(
                child: Text(
                  model.statusLabel,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF454652),
                    fontSize: 11,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ),
            ],
          ),
        );
      case _ModelStatus.inProgress:
        return Align(
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(
                'Step ${model.currentStep} of ${model.totalSteps}',
                style: const TextStyle(
                  color: Color(0xFF011D86),
                  fontSize: 11,
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.10,
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(9999),
                child: LinearProgressIndicator(
                  value: model.progress,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFEFEDF6),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFDC003),
                  ),
                ),
              ),
            ],
          ),
        );
      case _ModelStatus.locked:
        return Align(
          alignment: Alignment.bottomLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 14,
                color: Color(0xFF757684),
              ),
              Flexible(
                child: Text(
                  model.statusLabel,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: const TextStyle(
                    color: Color(0xFF757684),
                    fontSize: 11,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}

enum _ModelStatus { completed, inProgress, locked }

class _CollectionModel {
  const _CollectionModel({
    required this.title,
    required this.imageUrl,
    required this.difficultyLabel,
    required this.difficultyBg,
    required this.difficultyFg,
    required this.estimatedTime,
    required this.status,
    this.statusLabel = '',
    this.currentStep,
    this.totalSteps,
  });

  final String title;
  final String imageUrl;
  final String difficultyLabel;
  final Color difficultyBg;
  final Color difficultyFg;
  final String estimatedTime;
  final _ModelStatus status;

  /// Caption for completed/locked cards (e.g. "Completed 2d ago").
  final String statusLabel;

  /// Resume point for in-progress cards (e.g. 7 of 15).
  final int? currentStep;
  final int? totalSteps;

  double? get progress =>
      (currentStep != null && totalSteps != null && totalSteps! > 0)
      ? currentStep! / totalSteps!
      : null;

  /// Builds an [OrigamiModel] for the Model Details / Process View screens
  /// from this card's display data (placeholder steps; see CLAUDE.md §6).
  OrigamiModel toOrigamiModel() {
    final difficulty = switch (difficultyLabel) {
      'EASY' => Difficulty.easy,
      'MEDIUM' => Difficulty.medium,
      'HARD' => Difficulty.hard,
      _ => Difficulty.medium,
    };
    final minutes =
        int.tryParse(estimatedTime.replaceAll(RegExp(r'[^0-9]'), '')) ?? 10;
    return OrigamiModel.placeholder(
      id: title,
      name: title,
      thumbnail: imageUrl,
      difficulty: difficulty,
      estimatedMinutes: minutes,
      totalSteps: totalSteps ?? 12,
      description:
          'A traditional origami project. Follow each fold carefully to '
          'bring $title to life.',
      category: 'Models',
    );
  }
}
