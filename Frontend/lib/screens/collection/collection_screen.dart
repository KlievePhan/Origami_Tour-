import 'package:flutter/material.dart';

import '../../data/repositories/model_repository.dart';
import '../../models/origami_model.dart';
import '../../widgets/app_header.dart';
import '../../widgets/main_bottom_nav_bar.dart';
import '../model_details/model_details_screen.dart';

/// Collection screen (`/home/collection`).
///
/// UI ported from the Figma export; restructured into a real screen widget
/// with a working search field, filter chips, an overall-progress banner, and
/// a model grid. Models (including diagram/thumbnail URLs and fold steps)
/// are loaded from the Backend ASP.NET Core API via [ModelRepository]
/// (`GET /api/models`).
class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  final _searchController = TextEditingController();
  final _repository = ModelRepository();

  static const _difficulties = ['Easy', 'Medium', 'Hard'];

  String? _selectedDifficulty;
  String? _selectedCategory;
  String _searchQuery = '';

  List<OrigamiModel>? _models;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadModels();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  Future<void> _loadModels() async {
    setState(() => _error = null);
    try {
      final models = await _repository.getModels();
      if (!mounted) return;
      setState(() => _models = models);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    }
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

  /// Distinct categories present in the loaded models, used to build the
  /// category filter chips (the API may seed different categories than the
  /// original Figma placeholders).
  List<String> get _categories {
    final categories = (_models ?? const <OrigamiModel>[])
        .map((m) => m.category)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  List<OrigamiModel> get _filteredModels {
    return (_models ?? const <OrigamiModel>[]).where((model) {
      if (_selectedDifficulty != null &&
          model.difficulty.label != _selectedDifficulty) {
        return false;
      }
      if (_selectedCategory != null && model.category != _selectedCategory) {
        return false;
      }
      if (_searchQuery.isNotEmpty &&
          !model.name.toLowerCase().contains(_searchQuery)) {
        return false;
      }
      return true;
    }).toList();
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
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNavBar(current: MainTab.collection),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return _ErrorState(onRetry: _loadModels);
    }
    if (_models == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = _filteredModels;
    final categories = _categories;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _SearchBar(controller: _searchController),
        const SizedBox(height: 16),
        _FilterChipsRow(
          options: _difficulties,
          selected: _selectedDifficulty,
          onSelected: _toggleDifficulty,
        ),
        if (categories.isNotEmpty) ...[
          const SizedBox(height: 12),
          _FilterChipsRow(
            options: categories,
            selected: _selectedCategory,
            onSelected: _toggleCategory,
            pill: true,
          ),
        ],
        const SizedBox(height: 24),
        _OverallProgressCard(finished: 0, total: _models!.length),
        const SizedBox(height: 24),
        if (filtered.isEmpty)
          const _EmptyState()
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.72,
                ),
            itemBuilder: (context, index) =>
                _ModelGridCard(model: _CollectionModel(filtered[index])),
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
    );
  }
}

/// Shown when [ModelRepository.getModels] fails (e.g. the Backend API isn't
/// reachable at the configured base URL).
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 40,
              color: Color(0xFF757684),
            ),
            const SizedBox(height: 12),
            const Text(
              "Couldn't load models from the server.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF454652),
                fontSize: 16,
                fontFamily: 'Work Sans',
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

/// Shown when no model matches the active search/filters.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Text(
          'No models match your search or filters.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF757684),
            fontSize: 16,
            fontFamily: 'Work Sans',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
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
                  Image.network(
                    model.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFEFEDF6),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: Color(0xFF757684),
                      ),
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
/// step counter with a mini progress bar, or a "not started" hint — per the
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
      case _ModelStatus.notStarted:
        return Align(
          alignment: Alignment.bottomLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              const Icon(
                Icons.play_circle_outline,
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

enum _ModelStatus { completed, inProgress, notStarted }

/// Display-ready wrapper around an [OrigamiModel] fetched from the API.
///
/// Per-model progress (`completed` / `inProgress`) isn't available from the
/// catalog endpoint — `UserModelProgress` is out of scope for the current
/// API — so every card currently renders as "not started".
class _CollectionModel {
  _CollectionModel(this.model);

  final OrigamiModel model;

  String get title => model.name;
  String get imageUrl => model.thumbnail;
  String get estimatedTime => '${model.estimatedMinutes}m';
  String get difficultyLabel => model.difficulty.label.toUpperCase();
  Color get difficultyBg => _difficultyColors(model.difficulty).bg;
  Color get difficultyFg => _difficultyColors(model.difficulty).fg;

  _ModelStatus get status => _ModelStatus.notStarted;
  String get statusLabel => 'Not started yet';
  int? get currentStep => null;
  int? get totalSteps => null;
  double? get progress => null;

  OrigamiModel toOrigamiModel() => model;
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
