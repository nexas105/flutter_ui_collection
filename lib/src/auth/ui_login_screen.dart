import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../components/button/ui_button.dart';
import '../components/divider/ui_divider.dart';
import '../components/form/ui_form.dart';
import '../icons/ui_icons.dart';
import '../theme/ui_theme.dart';
import 'ui_auth_controller.dart';
import 'ui_auth_models.dart';
import 'ui_social_button.dart';

/// A complete, themed login screen.
///
/// Provides email/password fields, social login options, and navigation
/// links to register and forgot-password flows.
///
/// ```dart
/// UiLoginScreen(
///   controller: authController,
///   title: 'Welcome Back',
///   onForgotPassword: () => Navigator.pushNamed(context, '/forgot'),
///   onRegister: () => Navigator.pushNamed(context, '/register'),
/// )
/// ```
class UiLoginScreen extends StatefulWidget {
  const UiLoginScreen({
    super.key,
    this.controller,
    this.logo,
    this.title = 'Sign In',
    this.showSocial = true,
    this.socialProviders = const [
      UiSocialProvider.google,
      UiSocialProvider.apple,
    ],
    this.onForgotPassword,
    this.onRegister,
    this.onSuccess,
    this.maxWidth = 400.0,
  });

  /// Optional controller to manage auth state. If not provided, the screen
  /// manages its own state but requires callbacks on the controller.
  final UiAuthController? controller;

  /// Optional logo widget displayed above the title.
  final Widget? logo;

  /// Title text displayed at the top of the form.
  final String title;

  /// Whether to show social login options.
  final bool showSocial;

  /// Which social providers to show.
  final List<UiSocialProvider> socialProviders;

  /// Called when the user taps "Forgot password?".
  final VoidCallback? onForgotPassword;

  /// Called when the user taps "Register".
  final VoidCallback? onRegister;

  /// Called after a successful login.
  final VoidCallback? onSuccess;

  /// Maximum width of the form content.
  final double maxWidth;

  @override
  State<UiLoginScreen> createState() => _UiLoginScreenState();
}

class _UiLoginScreenState extends State<UiLoginScreen> {
  final _formKey = GlobalKey<UiFormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  UiAuthController? _internalController;
  UiAuthController get _controller =>
      widget.controller ?? (_internalController ??= UiAuthController());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onStateChanged);
  }

  @override
  void didUpdateWidget(UiLoginScreen oldWidget) {
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
    _passwordController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
    if (_controller.state == UiAuthState.success) {
      widget.onSuccess?.call();
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _controller.clearError();
    await _controller.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
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
          child: UiForm(
            key: _formKey,
            autovalidate: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: spacing.xxl),

                // Logo
                if (widget.logo != null) ...[
                  Center(child: widget.logo),
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
                SizedBox(height: spacing.xl),

                // Email field
                UiFormField(
                  fieldKey: 'email',
                  controller: _emailController,
                  label: 'Email',
                  placeholder: 'you@example.com',
                  prefixIcon: UiIcons.email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validators: [UiValidators.required, UiValidators.email],
                ),
                SizedBox(height: spacing.md),

                // Password field
                UiFormField(
                  fieldKey: 'password',
                  controller: _passwordController,
                  label: 'Password',
                  placeholder: 'Enter your password',
                  prefixIcon: UiIcons.lock,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  validators: [UiValidators.required],
                ),
                SizedBox(height: spacing.sm),

                // Password visibility + Forgot password row
                Row(
                  children: [
                    // Toggle password visibility
                    GestureDetector(
                      onTap: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _obscurePassword
                                  ? UiIcons.visibility
                                  : UiIcons.visibilityOff,
                              size: 16,
                              color: colors.resolvedOnSurfaceSubtle,
                            ),
                            SizedBox(width: spacing.xs),
                            Text(
                              _obscurePassword ? 'Show' : 'Hide',
                              style: typo.bodySmall.copyWith(
                                color: colors.resolvedOnSurfaceSubtle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Forgot password
                    if (widget.onForgotPassword != null)
                      GestureDetector(
                        onTap: widget.onForgotPassword,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Text(
                            'Forgot password?',
                            style: typo.bodySmall.copyWith(
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: spacing.lg),

                // Error message
                if (_controller.errorMessage != null) ...[
                  _AuthErrorBanner(message: _controller.errorMessage!),
                  SizedBox(height: spacing.md),
                ],

                // Login button
                UiButton(
                  label: 'Sign In',
                  onPressed: _controller.isLoading ? null : _submit,
                  variant: UiButtonVariant.glow,
                  expand: true,
                  loading: _controller.isLoading,
                ),

                // Social login section
                if (widget.showSocial && widget.socialProviders.isNotEmpty) ...[
                  SizedBox(height: spacing.lg),
                  const UiDivider(label: 'OR'),
                  SizedBox(height: spacing.lg),
                  ...widget.socialProviders.map(
                    (provider) => Padding(
                      padding: EdgeInsets.only(bottom: spacing.sm),
                      child: UiSocialButton(
                        provider: provider,
                        loading: _controller.isLoading,
                        onPressed: _controller.isLoading
                            ? null
                            : () => _controller.socialLogin(provider),
                      ),
                    ),
                  ),
                ],

                SizedBox(height: spacing.lg),

                // Register link
                if (widget.onRegister != null)
                  Center(
                    child: GestureDetector(
                      onTap: widget.onRegister,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "Don't have an account? ",
                                style: typo.bodySmall.copyWith(
                                  color: colors.onBackground,
                                ),
                              ),
                              TextSpan(
                                text: 'Register',
                                style: typo.bodySmall.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                SizedBox(height: spacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// An error banner that displays auth error messages.
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
        color: colors.error.withValues(alpha: theme.components.tintOpacity),
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
