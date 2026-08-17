import 'package:flutter/widgets.dart';

/// An application-wide icon replacement and rendering policy.
///
/// Keys are fallback icons exposed by `UiIcons`. Apps can replace any or all
/// icons with glyphs from their own font without changing component code.
class UiIconSet {
  const UiIconSet({
    this.replacements = const {},
    this.weight,
    this.grade,
    this.opticalSize,
  });

  final Map<IconData, IconData> replacements;
  final double? weight;
  final double? grade;
  final double? opticalSize;

  IconData resolve(IconData fallback) => replacements[fallback] ?? fallback;

  UiIconSet copyWith({
    Map<IconData, IconData>? replacements,
    double? weight,
    double? grade,
    double? opticalSize,
  }) {
    return UiIconSet(
      replacements: replacements ?? this.replacements,
      weight: weight ?? this.weight,
      grade: grade ?? this.grade,
      opticalSize: opticalSize ?? this.opticalSize,
    );
  }
}
