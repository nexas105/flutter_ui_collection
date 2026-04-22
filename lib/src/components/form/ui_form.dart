import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../text_field/ui_text_field.dart';

/// Signature for field validators.
///
/// Returns an error message string if validation fails, or `null` if valid.
typedef UiValidator = String? Function(String value);

/// A form that manages validation state for child [UiFormField] widgets.
///
/// ```dart
/// final _formKey = GlobalKey<UiFormState>();
///
/// UiForm(
///   key: _formKey,
///   child: Column(children: [
///     UiFormField(
///       label: 'Email',
///       validators: [UiValidators.required, UiValidators.email],
///     ),
///     UiButton(label: 'Submit', onPressed: () {
///       if (_formKey.currentState!.validate()) {
///         print(_formKey.currentState!.values);
///       }
///     }),
///   ]),
/// )
/// ```
class UiForm extends StatefulWidget {
  const UiForm({
    super.key,
    required this.child,
    this.onSubmit,
    this.autovalidate = false,
  });

  final Widget child;

  /// Called when [UiFormState.submit] is invoked and validation passes.
  final ValueChanged<Map<String, String>>? onSubmit;

  /// If true, fields validate on every change.
  final bool autovalidate;

  @override
  State<UiForm> createState() => UiFormState();

  static UiFormState? of(BuildContext context) {
    return context.findAncestorStateOfType<UiFormState>();
  }
}

class UiFormState extends State<UiForm> {
  final List<UiFormFieldState> _fields = [];

  void registerField(UiFormFieldState field) => _fields.add(field);
  void unregisterField(UiFormFieldState field) => _fields.remove(field);

  /// Validates all fields. Returns `true` if all pass.
  bool validate() {
    var valid = true;
    for (final field in _fields) {
      if (!field.validate()) valid = false;
    }
    return valid;
  }

  /// Validates and calls [UiForm.onSubmit] if valid.
  void submit() {
    if (validate()) widget.onSubmit?.call(values);
  }

  /// Map of field keys to current text values.
  Map<String, String> get values {
    final map = <String, String>{};
    for (final field in _fields) {
      final key = field.widget.fieldKey ??
          field.widget.label ??
          'field_${_fields.indexOf(field)}';
      map[key] = field.value;
    }
    return map;
  }

  /// Resets all fields.
  void reset() {
    for (final field in _fields) {
      field.reset();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// A form-aware text field with validation.
///
/// When inside a [UiForm], automatically registers itself and
/// participates in form-level validation and submission.
class UiFormField extends StatefulWidget {
  const UiFormField({
    super.key,
    this.fieldKey,
    this.controller,
    this.label,
    this.placeholder,
    this.helperText,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.autofocus = false,
    this.validators = const [],
    this.onChanged,
    this.initialValue,
    this.keyboardType,
    this.textInputAction,
  });

  /// Unique key in the form values map. Falls back to [label].
  final String? fieldKey;
  final TextEditingController? controller;
  final String? label;
  final String? placeholder;
  final String? helperText;
  final bool obscureText;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool autofocus;
  final String? initialValue;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<UiValidator> validators;
  final ValueChanged<String>? onChanged;

  @override
  State<UiFormField> createState() => UiFormFieldState();
}

class UiFormFieldState extends State<UiFormField> {
  late TextEditingController _controller;
  bool _ownsController = false;
  String? _errorText;
  bool _hasBeenValidated = false;
  UiFormState? _form;

  String get value => _controller.text;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController(text: widget.initialValue ?? '');
      _ownsController = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _form = UiForm.of(context);
      _form?.registerField(this);
    });
  }

  @override
  void dispose() {
    _form?.unregisterField(this);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  /// Validates against all validators. Returns `true` if valid.
  bool validate() {
    String? error;
    for (final validator in widget.validators) {
      error = validator(_controller.text);
      if (error != null) break;
    }
    setState(() {
      _errorText = error;
      _hasBeenValidated = true;
    });
    return error == null;
  }

  void reset() {
    _controller.text = widget.initialValue ?? '';
    setState(() {
      _errorText = null;
      _hasBeenValidated = false;
    });
  }

  void _onChanged(String val) {
    widget.onChanged?.call(val);
    final form = UiForm.of(context);
    if (_hasBeenValidated || (form != null && form.widget.autovalidate)) {
      validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return UiTextField(
      controller: _controller,
      label: widget.label,
      placeholder: widget.placeholder,
      helperText: widget.helperText,
      errorText: _errorText,
      obscureText: widget.obscureText,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      prefixIcon: widget.prefixIcon,
      suffixIcon: widget.suffixIcon,
      autofocus: widget.autofocus,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onChanged: _onChanged,
      onSubmitted: (_) => UiForm.of(context)?.submit(),
    );
  }
}

/// Built-in validators for common patterns.
///
/// ```dart
/// UiFormField(validators: [UiValidators.required, UiValidators.email])
/// ```
abstract final class UiValidators {
  static String? required(String value) {
    if (value.trim().isEmpty) return 'This field is required';
    return null;
  }

  static String? email(String value) {
    if (value.trim().isEmpty) return null;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
      return 'Invalid email address';
    }
    return null;
  }

  static UiValidator minLength(int length) => (String value) {
        if (value.length < length) return 'Minimum $length characters';
        return null;
      };

  static UiValidator maxLength(int length) => (String value) {
        if (value.length > length) return 'Maximum $length characters';
        return null;
      };

  static UiValidator pattern(RegExp regex, {String message = 'Invalid format'}) =>
      (String value) {
        if (value.isEmpty) return null;
        if (!regex.hasMatch(value)) return message;
        return null;
      };

  static UiValidator matches(String Function() getValue,
          {String message = 'Values do not match'}) =>
      (String value) {
        if (value != getValue()) return message;
        return null;
      };

  static String? numeric(String value) {
    if (value.isEmpty) return null;
    if (double.tryParse(value) == null) return 'Must be a number';
    return null;
  }
}
