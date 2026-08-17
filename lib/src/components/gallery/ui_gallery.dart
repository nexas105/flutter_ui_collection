import 'package:flutter/widgets.dart';

import '../../icons/ui_icons.dart';
import '../../theme/ui_theme.dart';
import '../../theme/ui_theme_data.dart';

/// A themed image gallery grid that opens images in a fullscreen viewer.
///
/// ```dart
/// UiGallery(
///   images: [
///     NetworkImage('https://...'),
///     NetworkImage('https://...'),
///   ],
///   crossAxisCount: 3,
/// )
/// ```
class UiGallery extends StatelessWidget {
  const UiGallery({
    super.key,
    required this.images,
    this.crossAxisCount = 3,
    this.spacing = 4.0,
    this.aspectRatio = 1.0,
    this.borderRadius,
    this.onImageTap,
  });

  final List<ImageProvider> images;
  final int crossAxisCount;
  final double spacing;
  final double aspectRatio;
  final BorderRadius? borderRadius;

  /// Custom tap handler. If null, opens fullscreen viewer.
  final void Function(int index)? onImageTap;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final radius = borderRadius ?? theme.spacing.radiusSm;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: aspectRatio,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            if (onImageTap != null) {
              onImageTap!(index);
            } else {
              _openViewer(context, index);
            }
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: ClipRRect(
              borderRadius: radius,
              child: Image(image: images[index], fit: BoxFit.cover),
            ),
          ),
        );
      },
    );
  }

  void _openViewer(BuildContext context, int startIndex) {
    final theme = UiTheme.of(context);

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: const Color(0xEE000000),
        barrierDismissible: true,
        transitionDuration: theme.animationDuration,
        pageBuilder: (ctx, anim, secAnim) {
          return FadeTransition(
            opacity: anim,
            child: _GalleryViewer(
              images: images,
              initialIndex: startIndex,
              theme: theme,
            ),
          );
        },
      ),
    );
  }
}

class _GalleryViewer extends StatefulWidget {
  const _GalleryViewer({
    required this.images,
    required this.initialIndex,
    required this.theme,
  });

  final List<ImageProvider> images;
  final int initialIndex;
  final UiThemeData theme;

  @override
  State<_GalleryViewer> createState() => _GalleryViewerState();
}

class _GalleryViewerState extends State<_GalleryViewer> {
  late final PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typo = widget.theme.typography;

    return Stack(
      children: [
        // Swipeable images
        PageView.builder(
          controller: _controller,
          itemCount: widget.images.length,
          onPageChanged: (i) => setState(() => _currentIndex = i),
          itemBuilder: (context, index) {
            return InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Image(image: widget.images[index], fit: BoxFit.contain),
              ),
            );
          },
        ),
        // Close button
        Positioned(
          top: 48,
          right: 16,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0x66000000),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    UiIcons.close,
                    size: 20,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Counter
        Positioned(
          bottom: 32,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0x66000000),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentIndex + 1} / ${widget.images.length}',
                style: typo.labelMedium.copyWith(
                  color: const Color(0xFFFFFFFF),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
