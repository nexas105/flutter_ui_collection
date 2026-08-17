import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../components/button/ui_button.dart';
import '../components/checkbox/ui_checkbox.dart';
import '../components/divider/ui_divider.dart';
import '../components/form/ui_form.dart';
import '../icons/ui_icons.dart';
import '../theme/ui_theme.dart';
import 'ui_auth_controller.dart';
import 'ui_auth_models.dart';
import 'ui_social_button.dart';

/// A complete, themed registration screen.
///
/// Provides name, email, password, and confirm-password fields with
/// validation, an optional terms checkbox, social registration, and
/// a link back to the login flow.
///
/// ```dart
/// UiRegisterScreen(
///   controller: authController,
///   onLogin: () => Navigator.pop(context),
/// )
/// ```
class UiRegisterScreen extends StatefulWidget {
  const UiRegisterScreen({
    super.key,
    this.controller,
    this.logo,
    this.title = 'Create Account',
    this.showSocial = true,
    this.socialProviders = const [
      UiSocialProvider.google,
      UiSocialProvider.apple,
    ],
    this.onLogin,
    this.onSuccess,
    this.requireTerms = false,
    this.termsText = 'I agree to the Terms & Privacy Policy',
    this.maxWidth = 400.0,
  });

  /// Optional controller to manage auth state.
  final UiAuthController? controller;

  /// Optional logo widget displayed above the title.
  final Widget? logo;

  /// Title text displayed at the top of the form.
  final String title;

  /// Whether to show social login options.
  final bool showSocial;

  /// Which social providers to show.
  final List<UiSocialProvider> socialProviders;

  /// Called when the user taps "Login".
  final VoidCallback? onLogin;

  /// Called after a successful registration.
  final VoidCallback? onSuccess;

  /// Whether the user must check the terms checkbox to register.
  final bool requireTerms;

  /// Label text for the terms checkbox.
  final String termsText;

  /// Maximum width of the form content.
  final double maxWidth;

  @override
  State<UiRegisterScreen> createState() => _UiRegisterScreenState();
}

class _UiRegisterScreenState extends State<UiRegisterScreen> {
  final _formKey = GlobalKey<UiFormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;
  String? _termsError;

  UiAuthController? _internalController;
  UiAuthController get _controller =>
      widget.controller ?? (_internalController ??= UiAuthController());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onStateChanged);
  }

  @override
  void didUpdateWidget(UiRegisterScreen oldWidget) {
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
    if (_controller.state == UiAuthState.success) {
      widget.onSuccess?.call();
    }
  }

  Future<void> _submit() async {
    final formValid = _formKey.currentState?.validate() ?? false;

    // Terms validation
    if (widget.requireTerms && !_agreedToTerms) {
      setState(() => _termsError = 'You must agree to the terms');
    } else {
      setState(() => _termsError = null);
    }

    if (!formValid || (widget.requireTerms && !_agreedToTerms)) return;

    _controller.clearError();
    await _controller.register(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
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

                // Name field
                UiFormField(
                  fieldKey: 'name',
                  controller: _nameController,
                  label: 'Name',
                  placeholder: 'Your full name',
                  prefixIcon: UiIcons.person,
                  textInputAction: TextInputAction.next,
                  validators: [UiValidators.required],
                ),
                SizedBox(height: spacing.md),

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
                  placeholder: 'At least 8 characters',
                  prefixIcon: UiIcons.lock,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  validators: [
                    UiValidators.required,
                    UiValidators.minLength(8),
                  ],
                ),
                SizedBox(height: spacing.xs),
                _PasswordVisibilityToggle(
                  obscure: _obscurePassword,
                  onTap: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                SizedBox(height: spacing.md),

                // Confirm Password field
                UiFormField(
                  fieldKey: 'confirmPassword',
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  placeholder: 'Re-enter your password',
                  prefixIcon: UiIcons.lock,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  validators: [
                    UiValidators.required,
                    UiValidators.matches(
                      () => _passwordController.text,
                      message: 'Passwords do not match',
                    ),
                  ],
                ),
                SizedBox(height: spacing.xs),
                _PasswordVisibilityToggle(
                  obscure: _obscureConfirm,
                  onTap: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                SizedBox(height: spacing.md),

                // Terms checkbox
                if (widget.requireTerms) ...[
                  UiCheckbox(
                    value: _agreedToTerms,
                    onChanged: (v) => setState(() {
                      _agreedToTerms = v ?? false;
                      if (_agreedToTerms) _termsError = null;
                    }),
                    label: widget.termsText,
                  ),
                  if (_termsError != null) ...[
                    SizedBox(height: spacing.xs),
                    Text(
                      _termsError!,
                      style: typo.bodySmall.copyWith(color: colors.error),
                    ),
                  ],
                  SizedBox(height: spacing.md),
                ],

                // Error message
                if (_controller.errorMessage != null) ...[
                  _AuthErrorBanner(message: _controller.errorMessage!),
                  SizedBox(height: spacing.md),
                ],

                // Register button
                UiButton(
                  label: 'Create Account',
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

                // Login link
                if (widget.onLogin != null)
                  Center(
                    child: GestureDetector(
                      onTap: widget.onLogin,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Already have an account? ',
                                style: typo.bodySmall.copyWith(
                                  color: colors.onBackground,
                                ),
                              ),
                              TextSpan(
                                text: 'Login',
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

class _PasswordVisibilityToggle extends StatelessWidget {
  const _PasswordVisibilityToggle({required this.obscure, required this.onTap});

  final bool obscure;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              obscure ? UiIcons.visibility : UiIcons.visibilityOff,
              size: 16,
              color: colors.resolvedOnSurfaceSubtle,
            ),
            SizedBox(width: spacing.xs),
            Text(
              obscure ? 'Show' : 'Hide',
              style: typo.bodySmall.copyWith(
                color: colors.resolvedOnSurfaceSubtle,
              ),
            ),
          ],
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
