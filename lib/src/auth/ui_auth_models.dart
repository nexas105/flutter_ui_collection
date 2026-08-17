import 'package:flutter/widgets.dart';

import '../icons/ui_icons.dart';

/// The current state of an authentication operation.
enum UiAuthState {
  /// No operation in progress.
  idle,

  /// An async operation is running.
  loading,

  /// The operation completed successfully.
  success,

  /// The operation failed.
  error,
}

/// The result of an authentication operation.
class UiAuthResult {
  const UiAuthResult({required this.success, this.errorMessage, this.userData});

  /// Whether the operation succeeded.
  final bool success;

  /// Human-readable error message when [success] is `false`.
  final String? errorMessage;

  /// Optional user data returned on success.
  final Map<String, dynamic>? userData;

  /// Convenience factory for a successful result.
  factory UiAuthResult.ok([Map<String, dynamic>? userData]) =>
      UiAuthResult(success: true, userData: userData);

  /// Convenience factory for a failed result.
  factory UiAuthResult.fail(String message) =>
      UiAuthResult(success: false, errorMessage: message);
}

/// Supported social login providers.
enum UiSocialProvider {
  google('Google', UiIcons.google),
  apple('Apple', UiIcons.apple),
  github('GitHub', UiIcons.code),
  facebook('Facebook', UiIcons.facebook),
  twitter('Twitter', UiIcons.twitter),
  custom('Custom', UiIcons.person);

  const UiSocialProvider(this.label, this.icon);

  /// Human-readable label for the provider.
  final String label;

  /// Default icon for the provider.
  final IconData icon;
}
