import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// Data class for a single onboarding page.
class UiOnboardingPage {
  const UiOnboardingPage({
    required this.title,
    required this.description,
    this.image,
  });

  final String title;
  final String description;
  final Widget? image;
}

/// An intro/walkthrough onboarding widget with paged content,
/// dot indicators, and skip/next/done navigation.
///
/// ```dart
/// UiOnboarding(
///   pages: [
///     UiOnboardingPage(title: 'Welcome', description: '...'),
///     UiOnboardingPage(title: 'Features', description: '...'),
///   ],
///   onCompleted: () => Navigator.pushReplacement(...),
/// )
/// ```
class UiOnboarding extends StatefulWidget {
  const UiOnboarding({
    super.key,
    required this.pages,
    required this.onCompleted,
    this.showSkip = true,
    this.nextLabel = 'Next',
    this.skipLabel = 'Skip',
    this.doneLabel = 'Done',
  });

  final List<UiOnboardingPage> pages;
  final VoidCallback onCompleted;
  final bool showSkip;
  final String nextLabel;
  final String skipLabel;
  final String doneLabel;

  @override
  State<UiOnboarding> createState() => _UiOnboardingState();
}

class _UiOnboardingState extends State<UiOnboarding> {
  late final PageController _pageController;
  int _currentPage = 0;

  bool get _isLastPage => _currentPage == widget.pages.length - 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLastPage) {
      widget.onCompleted();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() {
    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    return Column(
      children: [
        // Page content
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final page = widget.pages[index];
              return Padding(
                padding: spacing.paddingLg,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (page.image != null) ...[
                      page.image!,
                      SizedBox(height: spacing.xl),
                    ],
                    Text(
                      page.title,
                      style: typo.headlineMedium.copyWith(
                        color: colors.onBackground,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: spacing.md),
                    Text(
                      page.description,
                      style: typo.bodyMedium.copyWith(
                        color: colors.onBackground.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Bottom navigation
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.lg,
            vertical: spacing.md,
          ),
          child: Row(
            children: [
              // Skip button
              if (widget.showSkip && !_isLastPage)
                GestureDetector(
                  onTap: _skip,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      widget.skipLabel,
                      style: typo.labelLarge.copyWith(
                        color: colors.onBackground.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(width: 48),

              // Dots indicator
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.pages.length, (index) {
                    final isActive = index == _currentPage;
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: spacing.xs / 2),
                      child: AnimatedContainer(
                        duration: theme.animationDuration,
                        curve: theme.animationCurve,
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? colors.primary : colors.border,
                          borderRadius: spacing.radiusFull,
                          boxShadow: isActive &&
                                  theme.useGlow &&
                                  colors.glow != null
                              ? [
                                  BoxShadow(
                                    color:
                                        colors.glow!.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Next / Done button
              GestureDetector(
                onTap: _next,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: theme.animationDuration,
                    curve: theme.animationCurve,
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.md,
                      vertical: spacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: spacing.radiusFull,
                      boxShadow: theme.useGlow && colors.glow != null
                          ? [
                              BoxShadow(
                                color: colors.glow!.withValues(alpha: 0.3),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      _isLastPage ? widget.doneLabel : widget.nextLabel,
                      style:
                          typo.labelLarge.copyWith(color: colors.onPrimary),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
