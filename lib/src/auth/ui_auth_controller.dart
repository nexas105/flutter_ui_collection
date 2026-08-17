import 'package:flutter/widgets.dart';

import 'ui_auth_models.dart';

/// Signature for async auth callbacks.
typedef UiAuthCallback<T> = Future<UiAuthResult> Function(T args);

/// Arguments passed to the login callback.
class UiLoginArgs {
  const UiLoginArgs({required this.email, required this.password});
  final String email;
  final String password;
}

/// Arguments passed to the register callback.
class UiRegisterArgs {
  const UiRegisterArgs({
    required this.email,
    required this.password,
    this.name,
  });
  final String email;
  final String password;
  final String? name;
}

/// Arguments passed to the reset-password callback.
class UiResetPasswordArgs {
  const UiResetPasswordArgs({required this.email});
  final String email;
}

/// Arguments passed to the OTP verification callback.
class UiVerifyOtpArgs {
  const UiVerifyOtpArgs({required this.code});
  final String code;
}

/// Arguments passed to the social login callback.
class UiSocialLoginArgs {
  const UiSocialLoginArgs({required this.provider});
  final UiSocialProvider provider;
}

/// A [ChangeNotifier] that manages authentication state and delegates
/// operations to user-provided async callbacks.
///
/// ```dart
/// final controller = UiAuthController(
///   onLogin: (args) async {
///     final ok = await myAuthService.login(args.email, args.password);
///     return ok ? UiAuthResult.ok() : UiAuthResult.fail('Bad credentials');
///   },
/// );
/// ```
class UiAuthController extends ChangeNotifier {
  UiAuthController({
    this.onLogin,
    this.onRegister,
    this.onResetPassword,
    this.onVerifyOtp,
    this.onSocialLogin,
  });

  /// Called when the user submits the login form.
  UiAuthCallback<UiLoginArgs>? onLogin;

  /// Called when the user submits the register form.
  UiAuthCallback<UiRegisterArgs>? onRegister;

  /// Called when the user requests a password reset.
  UiAuthCallback<UiResetPasswordArgs>? onResetPassword;

  /// Called when the user submits an OTP code.
  UiAuthCallback<UiVerifyOtpArgs>? onVerifyOtp;

  /// Called when the user taps a social login button.
  UiAuthCallback<UiSocialLoginArgs>? onSocialLogin;

  UiAuthState _state = UiAuthState.idle;
  String? _errorMessage;

  /// The current auth state.
  UiAuthState get state => _state;

  /// The latest error message, if any.
  String? get errorMessage => _errorMessage;

  /// Whether an async operation is in progress.
  bool get isLoading => _state == UiAuthState.loading;

  /// Clears the current error and resets state to idle.
  void clearError() {
    _errorMessage = null;
    _state = UiAuthState.idle;
    notifyListeners();
  }

  /// Runs [onLogin] with the given credentials.
  Future<UiAuthResult> login(String email, String password) {
    return _run(onLogin, UiLoginArgs(email: email, password: password));
  }

  /// Runs [onRegister] with the given details.
  Future<UiAuthResult> register(String email, String password, String? name) {
    return _run(
      onRegister,
      UiRegisterArgs(email: email, password: password, name: name),
    );
  }

  /// Runs [onResetPassword] with the given email.
  Future<UiAuthResult> resetPassword(String email) {
    return _run(onResetPassword, UiResetPasswordArgs(email: email));
  }

  /// Runs [onVerifyOtp] with the given code.
  Future<UiAuthResult> verifyOtp(String code) {
    return _run(onVerifyOtp, UiVerifyOtpArgs(code: code));
  }

  /// Runs [onSocialLogin] with the given provider.
  Future<UiAuthResult> socialLogin(UiSocialProvider provider) {
    return _run(onSocialLogin, UiSocialLoginArgs(provider: provider));
  }

  Future<UiAuthResult> _run<T>(UiAuthCallback<T>? callback, T args) async {
    if (callback == null) {
      return UiAuthResult.fail('No callback configured');
    }

    _state = UiAuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await callback(args);
      if (result.success) {
        _state = UiAuthState.success;
        _errorMessage = null;
      } else {
        _state = UiAuthState.error;
        _errorMessage = result.errorMessage ?? 'An error occurred';
      }
    } catch (e) {
      _state = UiAuthState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
    return UiAuthResult(
      success: _state == UiAuthState.success,
      errorMessage: _errorMessage,
    );
  }
}
