import 'package:flutter/widgets.dart';

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
  const UiAuthResult({
    required this.success,
    this.errorMessage,
    this.userData,
  });

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
  google('Google', IconData(0xe1cb, fontFamily: 'MaterialIcons')),
  apple('Apple', IconData(0xf04be, fontFamily: 'MaterialIcons')),
  github('GitHub', IconData(0xe169, fontFamily: 'MaterialIcons')),
  facebook('Facebook', IconData(0xe27a, fontFamily: 'MaterialIcons')),
  twitter('Twitter', IconData(0xe602, fontFamily: 'MaterialIcons')),
  custom('Custom', IconData(0xe491, fontFamily: 'MaterialIcons'));

  const UiSocialProvider(this.label, this.icon);

  /// Human-readable label for the provider.
  final String label;

  /// Default icon for the provider.
  final IconData icon;
}
