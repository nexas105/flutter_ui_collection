import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../components/button/ui_button.dart';
import '../components/form/ui_form.dart';
import '../icons/ui_icons.dart';
import '../theme/ui_theme.dart';
import 'ui_auth_controller.dart';
import 'ui_auth_models.dart';

/// A themed forgot-password screen.
///
/// Shows a description, an email input, and a submit button. Displays
/// a success message once the reset request completes.
///
/// ```dart
/// UiForgotPasswordScreen(
///   controller: authController,
///   onBack: () => Navigator.pop(context),
/// )
/// ```
class UiForgotPasswordScreen extends StatefulWidget {
  const UiForgotPasswordScreen({
    super.key,
    this.controller,
    this.title = 'Forgot Password',
    this.description =
        'Enter the email address associated with your account and '
            "we'll send you a link to reset your password.",
    this.onBack,
    this.onSuccess,
    this.maxWidth = 400.0,
  });

  /// Optional controller to manage auth state.
  final UiAuthController? controller;

  /// Title text.
  final String title;

  /// Description shown below the title.
  final String description;

  /// Called when the user taps "Back to login".
  final VoidCallback? onBack;

  /// Called after a successful reset request.
  final VoidCallback? onSuccess;

  /// Maximum width of the form content.
  final double maxWidth;

  @override
  State<UiForgotPasswordScreen> createState() =>
      _UiForgotPasswordScreenState();
}

class _UiForgotPasswordScreenState extends State<UiForgotPasswordScreen> {
  final _formKey = GlobalKey<UiFormState>();
  final _emailController = TextEditingController();
  bool _submitted = false;

  UiAuthController? _internalController;
  UiAuthController get _controller =>
      widget.controller ?? (_internalController ??= UiAuthController());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onStateChanged);
  }

  @override
  void didUpdateWidget(UiForgotPasswordScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onStateChanged);
      _controller.addListener(_onStateChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _internalController?.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
    if (_controller.state == UiAuthState.success) {
      setState(() => _submitted = true);
      widget.onSuccess?.call();
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _controller.clearError();
    await _controller.resetPassword(_emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

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
                            'Back to login',
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
                  widget.description,
                  style: typo.bodyMedium.copyWith(
                    color: colors.onBackground.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: spacing.xl),

              if (_submitted) ...[
                // Success state
                _SuccessBanner(
                  message:
                      'Check your email! We sent a password reset link to '
                      '${_emailController.text.trim()}.',
                ),
                SizedBox(height: spacing.lg),
                UiButton(
                  label: 'Back to Login',
                  onPressed: widget.onBack,
                  variant: UiButtonVariant.outlined,
                  expand: true,
                ),
              ] else ...[
                // Form
                UiForm(
                  key: _formKey,
                  autovalidate: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      UiFormField(
                        fieldKey: 'email',
                        controller: _emailController,
                        label: 'Email',
                        placeholder: 'you@example.com',
                        prefixIcon: UiIcons.email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        validators: [
                          UiValidators.required,
                          UiValidators.email,
                        ],
                      ),
                      SizedBox(height: spacing.lg),

                      // Error message
                      if (_controller.errorMessage != null) ...[
                        _AuthErrorBanner(
                          message: _controller.errorMessage!,
                        ),
                        SizedBox(height: spacing.md),
                      ],

                      UiButton(
                        label: 'Send Reset Link',
                        onPressed: _controller.isLoading ? null : _submit,
                        variant: UiButtonVariant.glow,
                        expand: true,
                        loading: _controller.isLoading,
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: spacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner({required this.message});
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
        color: colors.success.withValues(alpha: 0.1),
        borderRadius: spacing.radiusMd,
        border: Border.all(
          color: colors.success.withValues(alpha: 0.3),
          width: theme.borderWidth,
        ),
      ),
      child: Row(
        children: [
          Icon(UiIcons.check, size: 16, color: colors.success),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Text(
              message,
              style: typo.bodySmall.copyWith(color: colors.success),
            ),
          ),
        ],
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
