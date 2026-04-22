import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A themed horizontal carousel / page slider with dot indicators.
///
/// ```dart
/// UiCarousel(
///   height: 200,
///   children: [
///     Image.network('https://...'),
///     UiCard(child: Text('Slide 2')),
///     UiCard(child: Text('Slide 3')),
///   ],
/// )
/// ```
class UiCarousel extends StatefulWidget {
  const UiCarousel({
    super.key,
    required this.children,
    this.height = 200,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.showIndicators = true,
    this.onPageChanged,
    this.viewportFraction = 1.0,
    this.initialPage = 0,
    this.padEnds = true,
  });

  final List<Widget> children;
  final double height;

  /// Automatically advance pages.
  final bool autoPlay;

  final Duration autoPlayInterval;
  final bool showIndicators;
  final ValueChanged<int>? onPageChanged;

  /// Fraction of viewport each page occupies (1.0 = full width).
  final double viewportFraction;

  final int initialPage;
  final bool padEnds;

  @override
  State<UiCarousel> createState() => _UiCarouselState();
}

class _UiCarouselState extends State<UiCarousel> {
  late final PageController _controller;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _controller = PageController(
      initialPage: widget.initialPage,
      viewportFraction: widget.viewportFraction,
    );
    if (widget.autoPlay) _startAutoPlay();
  }

  void _startAutoPlay() {
    Future.doWhile(() async {
      await Future.delayed(widget.autoPlayInterval);
      if (!mounted) return false;
      final next = (_currentPage + 1) % widget.children.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      return mounted && widget.autoPlay;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.children.length,
            padEnds: widget.padEnds,
            onPageChanged: (i) {
              setState(() => _currentPage = i);
              widget.onPageChanged?.call(i);
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.viewportFraction < 1.0 ? spacing.xs : 0,
                ),
                child: widget.children[index],
              );
            },
          ),
        ),
        if (widget.showIndicators && widget.children.length > 1) ...[
          SizedBox(height: spacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < widget.children.length; i++) ...[
                if (i > 0) SizedBox(width: spacing.xs),
                GestureDetector(
                  onTap: () => _controller.animateToPage(
                    i,
                    duration: theme.animationDuration,
                    curve: theme.animationCurve,
                  ),
                  child: AnimatedContainer(
                    duration: theme.animationDuration,
                    width: i == _currentPage ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _currentPage
                          ? colors.primary
                          : colors.border,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: i == _currentPage &&
                              theme.useGlow &&
                              colors.glow != null
                          ? [
                              BoxShadow(
                                color: colors.glow!.withValues(alpha: 0.4),
                                blurRadius: 6,
                              )
                            ]
                          : null,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
