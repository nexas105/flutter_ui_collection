import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A themed image widget that opens a fullscreen zoomable dialog on tap.
///
/// ```dart
/// UiImageViewer(
///   image: NetworkImage('https://example.com/photo.jpg'),
///   width: double.infinity,
///   height: 200,
///   fit: BoxFit.cover,
///   borderRadius: theme.spacing.radiusMd,
/// )
/// ```
class UiImageViewer extends StatelessWidget {
  const UiImageViewer({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.heroTag,
    this.placeholder,
  });

  final ImageProvider image;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  /// Optional hero tag for shared-element transition into fullscreen.
  final Object? heroTag;

  /// Widget shown while the image loads.
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final radius = borderRadius ?? theme.spacing.radiusMd;

    Widget imageWidget = ClipRRect(
      borderRadius: radius,
      child: Image(
        image: image,
        width: width,
        height: height,
        fit: fit,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) return child;
          return placeholder ??
              Container(
                width: width,
                height: height,
                color: theme.colorScheme.surface,
                child: Center(
                  child: Icon(
                    const IconData(0xe332, fontFamily: 'MaterialIcons'),
                    size: 32,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
                ),
              );
        },
      ),
    );

    if (heroTag != null) {
      imageWidget = Hero(tag: heroTag!, child: imageWidget);
    }

    return GestureDetector(
      onTap: () => _openFullscreen(context),
      child: MouseRegion(
        cursor: SystemMouseCursors.zoomIn,
        child: imageWidget,
      ),
    );
  }

  void _openFullscreen(BuildContext context) {
    final theme = UiTheme.of(context);

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: const Color(0xEE000000),
        barrierDismissible: true,
        transitionDuration: theme.animationDuration,
        reverseTransitionDuration: theme.animationDuration,
        pageBuilder: (ctx, animation, secondaryAnimation) {
          return _FullscreenView(
            image: image,
            heroTag: heroTag,
            animation: animation,
          );
        },
        transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

class _FullscreenView extends StatefulWidget {
  const _FullscreenView({
    required this.image,
    this.heroTag,
    required this.animation,
  });

  final ImageProvider image;
  final Object? heroTag;
  final Animation<double> animation;

  @override
  State<_FullscreenView> createState() => _FullscreenViewState();
}

class _FullscreenViewState extends State<_FullscreenView> {
  final TransformationController _transformController =
      TransformationController();

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = InteractiveViewer(
      transformationController: _transformController,
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: Image(
          image: widget.image,
          fit: BoxFit.contain,
        ),
      ),
    );

    if (widget.heroTag != null) {
      imageWidget = Hero(tag: widget.heroTag!, child: imageWidget);
    }

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      onDoubleTap: _resetZoom,
      child: Stack(
        children: [
          Positioned.fill(child: imageWidget),
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
                  decoration: BoxDecoration(
                    color: const Color(0x66000000),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      IconData(0xe16a, fontFamily: 'MaterialIcons'),
                      size: 20,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
