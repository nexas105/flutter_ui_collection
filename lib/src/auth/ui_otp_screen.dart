import 'dart:async';

import 'package:flutter/widgets.dart';

import '../components/button/ui_button.dart';
import '../components/pin_input/ui_pin_input.dart';
import '../icons/ui_icons.dart';
import '../theme/ui_theme.dart';
import 'ui_auth_controller.dart';
import 'ui_auth_models.dart';

/// A themed OTP verification screen.
///
/// Shows a PIN input, a countdown-based resend link, and a verify button.
///
/// ```dart
/// UiOtpScreen(
///   controller: authController,
///   email: 'user@example.com',
///   onResend: () async => await myApi.resendOtp(),
/// )
/// ```
class UiOtpScreen extends StatefulWidget {
  const UiOtpScreen({
    super.key,
    this.controller,
    this.length = 6,
    this.email,
    this.title = 'Verify Your Email',
    this.description,
    this.onResend,
    this.onBack,
    this.onSuccess,
    this.resendCooldown = const Duration(seconds: 60),
    this.maxWidth = 400.0,
  });

  /// Optional controller to manage auth state.
  final UiAuthController? controller;

  /// Number of OTP digits.
  final int length;

  /// Email address to display in the description.
  final String? email;

  /// Title text.
  final String title;

  /// Custom description. If null, a default is generated from [email].
  final String? description;

  /// Called when the user taps "Resend code".
  final VoidCallback? onResend;

  /// Called when the user taps "Back".
  final VoidCallback? onBack;

  /// Called after a successful verification.
  final VoidCallback? onSuccess;

  /// Cooldown duration before the user can resend.
  final Duration resendCooldown;

  /// Maximum width of the content.
  final double maxWidth;

  @override
  State<UiOtpScreen> createState() => _UiOtpScreenState();
}

class _UiOtpScreenState extends State<UiOtpScreen> {
  String _code = '';
  int _remainingSeconds = 0;
  Timer? _timer;

  UiAuthController? _internalController;
  UiAuthController get _controller =>
      widget.controller ?? (_internalController ??= UiAuthController());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onStateChanged);
    _startCooldown();
  }

  @override
  void didUpdateWidget(UiOtpScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onStateChanged);
      _controller.addListener(_onStateChanged);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.removeListener(_onStateChanged);
    _internalController?.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
    if (_controller.state == UiAuthState.success) {
      widget.onSuccess?.call();
    }
  }

  void _startCooldown() {
    _remainingSeconds = widget.resendCooldown.inSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          timer.cancel();
        }
      });
    });
  }

  void _resend() {
    widget.onResend?.call();
    _startCooldown();
  }

  Future<void> _verify() async {
    if (_code.length != widget.length) return;
    _controller.clearError();
    await _controller.verifyOtp(_code);
  }

  String get _resolvedDescription {
    if (widget.description != null) return widget.description!;
    if (widget.email != null) {
      return 'Enter the ${widget.length}-digit code sent to ${widget.email}';
    }
    return 'Enter the ${widget.length}-digit verification code';
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final canResend = _remainingSeconds <= 0 && widget.onResend != null;

    return SingleChildScrollView(
      padding: spacing.paddingLg,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widget.maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: spacing.xxl),

              // Back button
              if (widget.onBack != null) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: widget.onBack,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            UiIcons.arrowBack,
                            size: 18,
                            color: colors.onBackground,
                          ),
                          SizedBox(width: spacing.xs),
                          Text(
                            'Back',
                            style: typo.bodySmall.copyWith(
                              color: colors.onBackground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: spacing.lg),
              ],

              // Title
              Center(
                child: Text(
                  widget.title,
                  style: typo.headlineMedium.copyWith(
                    color: colors.onBackground,
                  ),
                ),
              ),
              SizedBox(height: spacing.md),

              // Description
              Center(
                child: Text(
                  _resolvedDescription,
                  style: typo.bodyMedium.copyWith(
                    color: colors.onBackground.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: spacing.xl),

              // PIN input
              Center(
                child: UiPinInput(
                  length: widget.length,
                  onChanged: (value) => setState(() => _code = value),
                  onCompleted: (_) => _verify(),
                ),
              ),
              SizedBox(height: spacing.lg),

              // Error message
              if (_controller.errorMessage != null) ...[
                _AuthErrorBanner(message: _controller.errorMessage!),
                SizedBox(height: spacing.md),
              ],

              // Verify button
              UiButton(
                label: 'Verify',
                onPressed: (_controller.isLoading ||
                        _code.length != widget.length)
                    ? null
                    : _verify,
                variant: UiButtonVariant.glow,
                expand: true,
                loading: _controller.isLoading,
              ),
              SizedBox(height: spacing.lg),

              // Resend section
              Center(
                child: canResend
                    ? GestureDetector(
                        onTap: _resend,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Text(
                            'Resend code',
                            style: typo.bodySmall.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        widget.onResend != null
                            ? 'Resend code in ${_formatTime(_remainingSeconds)}'
                            : 'Check your email for the code',
                        style: typo.bodySmall.copyWith(
                          color: colors.onBackground.withValues(alpha: 0.5),
                        ),
                      ),
              ),

              SizedBox(height: spacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthErrorBanner extends StatelessWidget {
  const _AuthErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.1),
        borderRadius: spacing.radiusMd,
        border: Border.all(
          color: colors.error.withValues(alpha: 0.3),
          width: theme.borderWidth,
        ),
      ),
      child: Row(
        children: [
          Icon(UiIcons.error, size: 16, color: colors.error),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Text(
              message,
              style: typo.bodySmall.copyWith(color: colors.error),
            ),
          ),
        ],
      ),
    );
  }
}
