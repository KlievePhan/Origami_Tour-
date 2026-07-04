import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/fold_step.dart';
import '../../models/origami_model.dart';
import '../../providers/bookmark_provider.dart';
import '../finish/finish_screen.dart';

/// Process View / step-by-step tutorial screen (`/model/:id/fold`).
///
/// Walks through [OrigamiModel.steps] one at a time: a diagram viewer, fold
/// instruction, optional tip card, top progress bar, step counter, and
/// Previous/Next navigation. "Finish Tutorial" on the last step opens
/// [FinishScreen] (CLAUDE.md §10, screen #8). Per CLAUDE.md §9-B this screen
/// also offers:
///  - a **bookmark** button in the header that favorites the model (shared
///    with [ModelDetailsScreen]'s favorite toggle, via [BookmarkProvider])
///  - **Cancel** ("X") → confirmation dialog → auto-saves the current step →
///    returns to the previous screen
class ProcessViewScreen extends StatefulWidget {
  const ProcessViewScreen({super.key, required this.model, this.startStep = 1});

  final OrigamiModel model;

  /// 1-based step to open the tutorial on (resume point).
  final int startStep;

  @override
  State<ProcessViewScreen> createState() => _ProcessViewScreenState();
}

class _ProcessViewScreenState extends State<ProcessViewScreen> {
  late int _currentStep = widget.startStep.clamp(1, widget.model.steps.length);

  int get _totalSteps => widget.model.steps.length;

  FoldStep get _step => widget.model.steps[_currentStep - 1];

  double get _progress => _currentStep / _totalSteps;

  /// Persists [_currentStep] as this model's resume point
  /// (`PUT /api/bookmarks/progress/{modelId}`).
  Future<void> _saveStep({bool silent = false}) async {
    await context.read<BookmarkProvider>().saveProgress(
      widget.model,
      _currentStep,
    );
    if (!silent && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Step $_currentStep of $_totalSteps saved.')),
        );
    }
  }

  void _toggleBookmark() {
    context.read<BookmarkProvider>().toggleFavorite(widget.model);
  }

  void _goToPrevious() {
    if (_currentStep <= 1) return;
    setState(() => _currentStep -= 1);
    _saveStep(silent: true);
  }

  void _goToNext() {
    if (_currentStep >= _totalSteps) {
      _finishTutorial();
      return;
    }
    setState(() => _currentStep += 1);
    _saveStep(silent: true);
  }

  /// Replaces this screen with [FinishScreen] once the last step is complete,
  /// and drops the model out of the "In Progress" list.
  void _finishTutorial() {
    context.read<BookmarkProvider>().removeProgress(widget.model);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => FinishScreen(
          modelTitle: widget.model.name,
          modelThumbnailUrl: widget.model.thumbnail,
        ),
      ),
    );
  }

  /// "Cancel" → confirmation dialog → persists progress → returns to the
  /// previous screen.
  Future<void> _handleCancel() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave tutorial?'),
        content: Text(
          'Your progress (step $_currentStep of $_totalSteps) will be saved automatically.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep folding'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save & exit'),
          ),
        ],
      ),
    );

    if (shouldExit != true || !mounted) return;

    await _saveStep(silent: true);
    if (!mounted) return;

    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              modelTitle: widget.model.name,
              currentStep: _currentStep,
              totalSteps: _totalSteps,
              isBookmarked: context.watch<BookmarkProvider>().isFavorite(
                widget.model.id,
              ),
              onCancel: _handleCancel,
              onToggleBookmark: _toggleBookmark,
            ),
            _TopProgressBar(progress: _progress),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                children: [
                  Text(
                    _step.foldType.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF1A1B21),
                      fontSize: 28,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w600,
                      height: 1.29,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _step.instruction,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF454652),
                      fontSize: 16,
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                      letterSpacing: 0.50,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _DiagramCard(
                    imageUrl: _step.diagramAsset,
                    onSwipeLeft: _goToNext,
                    onSwipeRight: _goToPrevious,
                  ),
                  if (_step.tip != null) ...[
                    const SizedBox(height: 24),
                    _TipCard(text: _step.tip!),
                  ],
                ],
              ),
            ),
            _BottomNavBar(
              isFirstStep: _currentStep <= 1,
              isLastStep: _currentStep >= _totalSteps,
              onPrevious: _goToPrevious,
              onNext: _goToNext,
            ),
          ],
        ),
      ),
    );
  }
}

/// Thin top-of-screen bar showing overall tutorial completion.
class _TopProgressBar extends StatelessWidget {
  const _TopProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 4,
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 4,
        backgroundColor: const Color(0xFFEDEEEF),
        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF011D86)),
      ),
    );
  }
}

/// App bar: cancel ("X") button, "Tutorial" / model title, step counter pill,
/// and a bookmark toggle that saves the current step as the resume point.
class _Header extends StatelessWidget {
  const _Header({
    required this.modelTitle,
    required this.currentStep,
    required this.totalSteps,
    required this.isBookmarked,
    required this.onCancel,
    required this.onToggleBookmark,
  });

  final String modelTitle;
  final int currentStep;
  final int totalSteps;
  final bool isBookmarked;
  final VoidCallback onCancel;
  final VoidCallback onToggleBookmark;

  @override
  Widget build(BuildContext context) {
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
          Row(
            spacing: 16,
            children: [
              IconButton(
                onPressed: onCancel,
                icon: const Icon(Icons.close, color: Color(0xFF454652)),
                tooltip: 'Cancel',
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tutorial',
                    style: TextStyle(
                      color: Color(0xFF454652),
                      fontSize: 11,
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                      letterSpacing: 0.50,
                    ),
                  ),
                  Text(
                    modelTitle,
                    style: const TextStyle(
                      color: Color(0xFF011D86),
                      fontSize: 22,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      height: 1.27,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            spacing: 8,
            children: [
              IconButton(
                onPressed: onToggleBookmark,
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_add_outlined,
                  color: const Color(0xFF011D86),
                ),
                tooltip: isBookmarked
                    ? 'Remove bookmark'
                    : 'Bookmark this step',
              ),
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: const Color(0xFF24389C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
                child: Text(
                  '$currentStep/$totalSteps',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF9DABFF),
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
        ],
      ),
    );
  }
}

/// Diagram viewer card with a "Tap to inspect" affordance overlay.
class _DiagramCard extends StatelessWidget {
  const _DiagramCard({
    required this.imageUrl,
    this.onSwipeLeft,
    this.onSwipeRight,
  });

  final String imageUrl;

  /// Triggered by a fast horizontal swipe while the diagram is at its
  /// default (non-zoomed) scale — left advances to the next step, right
  /// returns to the previous one. Disabled while zoomed in, where a drag
  /// instead pans the enlarged image (see [_ZoomableDiagram]).
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 358,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0x4CC5C5D4)),
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
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.50, 0.50),
                    radius: 0.71,
                    colors: [Color(0xFF24389C), Color(0x0024389C)],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _ZoomableDiagram(
                imageUrl: imageUrl,
                onSwipeLeft: onSwipeLeft,
                onSwipeRight: onSwipeRight,
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: ShapeDecoration(
                color: const Color(0xCCE9E7F0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: const [
                  Icon(
                    Icons.touch_app_outlined,
                    size: 16,
                    color: Color(0xFF454652),
                  ),
                  Text(
                    'Double tap or pinch to zoom',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF454652),
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
          ),
        ],
      ),
    );
  }
}

/// Pinch-to-zoom + drag-to-pan + double-tap-to-zoom diagram viewer, plus
/// swipe-to-change-step while not zoomed in.
///
/// Built on [InteractiveViewer], which natively handles pinch zoom and pan;
/// double-tap-to-zoom is layered on top via a [GestureDetector] driving the
/// shared [TransformationController] (InteractiveViewer has no built-in
/// double-tap gesture). At the default 1x scale there's nothing to pan to,
/// so [InteractiveViewer]'s own pan is disabled there and a horizontal swipe
/// instead calls [onSwipeLeft]/[onSwipeRight] (next/previous step) — once
/// zoomed in, panning takes back over and swipes move the image instead.
class _ZoomableDiagram extends StatefulWidget {
  const _ZoomableDiagram({
    required this.imageUrl,
    this.onSwipeLeft,
    this.onSwipeRight,
  });

  final String imageUrl;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;

  @override
  State<_ZoomableDiagram> createState() => _ZoomableDiagramState();
}

class _ZoomableDiagramState extends State<_ZoomableDiagram> {
  static const _zoomScale = 2.5;
  static const _minSwipeVelocity = 200.0;

  final _controller = TransformationController();
  Offset _doubleTapPosition = Offset.zero;

  bool get _isZoomedIn => _controller.value.getMaxScaleOnAxis() > 1.01;

  @override
  void initState() {
    super.initState();
    // Pinch/pan gestures mutate _controller.value directly (bypassing our
    // setState calls), so listen for them to keep panEnabled/swipe-gating
    // in sync with the live zoom level.
    _controller.addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTransformChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTransformChanged() => setState(() {});

  void _onDoubleTapDown(TapDownDetails details) {
    _doubleTapPosition = details.localPosition;
  }

  void _onDoubleTap() {
    final isZoomedIn = _isZoomedIn;
    setState(() {
      _controller.value = isZoomedIn
          ? Matrix4.identity()
          : (Matrix4.identity()
              ..translateByDouble(
                -_doubleTapPosition.dx * (_zoomScale - 1),
                -_doubleTapPosition.dy * (_zoomScale - 1),
                0,
                1,
              )
              ..scaleByDouble(_zoomScale, _zoomScale, _zoomScale, 1));
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity <= -_minSwipeVelocity) {
      widget.onSwipeLeft?.call();
    } else if (velocity >= _minSwipeVelocity) {
      widget.onSwipeRight?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isZoomedIn = _isZoomedIn;
    return GestureDetector(
      onDoubleTapDown: _onDoubleTapDown,
      onDoubleTap: _onDoubleTap,
      onHorizontalDragEnd: isZoomedIn ? null : _onHorizontalDragEnd,
      child: InteractiveViewer(
        transformationController: _controller,
        minScale: 1,
        maxScale: 4,
        panEnabled: isZoomedIn,
        child: Image.network(
          widget.imageUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Container(
            decoration: const BoxDecoration(color: Color(0xFFEEF2FF)),
            alignment: Alignment.center,
            child: const Icon(
              Icons.broken_image_outlined,
              color: Color(0xFF757684),
            ),
          ),
        ),
      ),
    );
  }
}

/// Teal tip card offering a folding hint for the current step.
class _TipCard extends StatelessWidget {
  const _TipCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: const Color(0xFFB0EFE2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: Color(0xFF00201C)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF00201C),
                fontSize: 14,
                fontFamily: 'Work Sans',
                fontWeight: FontWeight.w400,
                height: 1.43,
                letterSpacing: 0.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom navigation bar with Previous / Next ("Finish Tutorial" on the last
/// step) controls.
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.isFirstStep,
    required this.isLastStep,
    required this.onPrevious,
    required this.onNext,
  });

  final bool isFirstStep;
  final bool isLastStep;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

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
      child: Row(
        spacing: 16,
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isFirstStep ? null : onPrevious,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(64),
                side: const BorderSide(width: 2, color: Color(0xFF011D86)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.arrow_back, color: Color(0xFF011D86)),
              label: const Text(
                'Previous',
                style: TextStyle(
                  color: Color(0xFF011D86),
                  fontSize: 22,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w500,
                  height: 1.27,
                ),
              ),
            ),
          ),
          Expanded(
            child: FilledButton.icon(
              onPressed: onNext,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(64),
                backgroundColor: const Color(0xFF011D86),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shadowColor: const Color(0x19000000),
              ),
              icon: Icon(
                isLastStep ? Icons.flag_outlined : Icons.arrow_forward,
                color: Colors.white,
              ),
              label: Text(
                isLastStep ? 'Finish Tutorial' : 'Next Step',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w500,
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
