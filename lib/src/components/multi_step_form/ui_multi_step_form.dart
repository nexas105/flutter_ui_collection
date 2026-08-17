import 'package:flutter/widgets.dart';

import '../../icons/ui_icons.dart';
import '../../theme/ui_theme.dart';

/// A single step in a multi-step form.
class UiFormStep {
  const UiFormStep({
    required this.title,
    required this.content,
    this.validator,
    this.icon,
  });

  final String title;
  final Widget content;

  /// Optional validator called before advancing. Return `true` to proceed.
  final bool Function()? validator;

  final IconData? icon;
}

/// A themed multi-step form wizard.
///
/// Manages step navigation, per-step validation, and provides
/// Next/Back/Submit controls.
///
/// ```dart
/// UiMultiStepForm(
///   steps: [
///     UiFormStep(
///       title: 'Account',
///       content: Column(children: [
///         UiFormField(label: 'Email', validators: [UiValidators.required]),
///       ]),
///       validator: () => _formKey1.currentState!.validate(),
///     ),
///     UiFormStep(title: 'Details', content: DetailsForm()),
///     UiFormStep(title: 'Confirm', content: ConfirmView()),
///   ],
///   onCompleted: () => print('Done!'),
/// )
/// ```
class UiMultiStepForm extends StatefulWidget {
  const UiMultiStepForm({
    super.key,
    required this.steps,
    this.onCompleted,
    this.onStepChanged,
    this.nextLabel = 'Next',
    this.backLabel = 'Back',
    this.submitLabel = 'Submit',
    this.showStepIndicator = true,
    this.nextBuilder,
    this.backBuilder,
    this.submitBuilder,
  });

  final List<UiFormStep> steps;

  /// Called when the user completes the last step.
  final VoidCallback? onCompleted;

  /// Called whenever the step index changes.
  final ValueChanged<int>? onStepChanged;

  final String nextLabel;
  final String backLabel;
  final String submitLabel;
  final bool showStepIndicator;

  /// Custom builder for the next button. Receives the onNext callback.
  final Widget Function(VoidCallback onNext)? nextBuilder;

  /// Custom builder for the back button.
  final Widget Function(VoidCallback onBack)? backBuilder;

  /// Custom builder for the submit button.
  final Widget Function(VoidCallback onSubmit)? submitBuilder;

  @override
  State<UiMultiStepForm> createState() => UiMultiStepFormState();
}

class UiMultiStepFormState extends State<UiMultiStepForm> {
  int _currentStep = 0;

  int get currentStep => _currentStep;
  bool get isFirstStep => _currentStep == 0;
  bool get isLastStep => _currentStep == widget.steps.length - 1;

  void next() {
    final step = widget.steps[_currentStep];
    if (step.validator != null && !step.validator!()) return;

    if (isLastStep) {
      widget.onCompleted?.call();
    } else {
      setState(() => _currentStep++);
      widget.onStepChanged?.call(_currentStep);
    }
  }

  void back() {
    if (!isFirstStep) {
      setState(() => _currentStep--);
      widget.onStepChanged?.call(_currentStep);
    }
  }

  void goTo(int step) {
    if (step >= 0 && step < widget.steps.length) {
      setState(() => _currentStep = step);
      widget.onStepChanged?.call(_currentStep);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Step indicator
        if (widget.showStepIndicator) ...[
          Row(
            children: [
              for (int i = 0; i < widget.steps.length; i++) ...[
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: i <= _currentStep ? colors.primary : colors.border,
                    ),
                  ),
                GestureDetector(
                  onTap: i < _currentStep ? () => goTo(i) : null,
                  child: MouseRegion(
                    cursor: i < _currentStep
                        ? SystemMouseCursors.click
                        : SystemMouseCursors.basic,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: theme.animationDuration,
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: i <= _currentStep
                                ? colors.primary
                                : colors.border,
                            shape: BoxShape.circle,
                            boxShadow:
                                i == _currentStep &&
                                    theme.useGlow &&
                                    colors.glow != null
                                ? [
                                    BoxShadow(
                                      color: colors.glow!.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: i < _currentStep
                                ? Icon(
                                    UiIcons.check,
                                    size: 16,
                                    color: colors.onPrimary,
                                  )
                                : Text(
                                    '${i + 1}',
                                    style: typo.labelSmall.copyWith(
                                      color: i <= _currentStep
                                          ? colors.onPrimary
                                          : colors.onSurface,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: spacing.xs),
                        Text(
                          widget.steps[i].title,
                          style: typo.labelSmall.copyWith(
                            color: i == _currentStep
                                ? colors.primary
                                : colors.onSurface.withValues(alpha: 0.5),
                            fontWeight: i == _currentStep
                                ? FontWeight.w600
                                : null,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: spacing.lg),
        ],

        // Step content
        Expanded(
          child: AnimatedSwitcher(
            duration: theme.animationDuration,
            switchInCurve: theme.animationCurve,
            child: KeyedSubtree(
              key: ValueKey(_currentStep),
              child: widget.steps[_currentStep].content,
            ),
          ),
        ),

        // Navigation buttons
        SizedBox(height: spacing.md),
        Row(
          children: [
            if (!isFirstStep)
              widget.backBuilder?.call(back) ??
                  GestureDetector(
                    onTap: back,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing.md,
                          vertical: spacing.sm,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: spacing.radiusMd,
                          border: Border.all(
                            color: colors.border,
                            width: theme.borderWidth,
                          ),
                        ),
                        child: Text(
                          widget.backLabel,
                          style: typo.labelMedium.copyWith(
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
            const Spacer(),
            isLastStep
                ? (widget.submitBuilder?.call(next) ??
                      GestureDetector(
                        onTap: next,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: spacing.md,
                              vertical: spacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: spacing.radiusMd,
                            ),
                            child: Text(
                              widget.submitLabel,
                              style: typo.labelMedium.copyWith(
                                color: colors.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ))
                : (widget.nextBuilder?.call(next) ??
                      GestureDetector(
                        onTap: next,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: spacing.md,
                              vertical: spacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: spacing.radiusMd,
                            ),
                            child: Text(
                              widget.nextLabel,
                              style: typo.labelMedium.copyWith(
                                color: colors.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      )),
          ],
        ),
      ],
    );
  }
}
