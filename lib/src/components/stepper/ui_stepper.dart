import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';
import '../../theme/ui_theme_data.dart';

/// State of a stepper step.
enum UiStepState { pending, active, completed, error }

/// A single step definition.
class UiStep {
  const UiStep({
    required this.title,
    this.subtitle,
    this.content,
    this.state = UiStepState.pending,
  });

  final String title;
  final String? subtitle;
  final Widget? content;
  final UiStepState state;
}

/// A themed stepper / wizard component.
///
/// ```dart
/// UiStepper(
///   currentStep: _step,
///   steps: [
///     UiStep(title: 'Account', content: AccountForm()),
///     UiStep(title: 'Details', content: DetailsForm()),
///     UiStep(title: 'Confirm', content: ConfirmView()),
///   ],
///   onStepTapped: (i) => setState(() => _step = i),
/// )
/// ```
class UiStepper extends StatelessWidget {
  const UiStepper({
    super.key,
    required this.steps,
    required this.currentStep,
    this.onStepTapped,
    this.orientation = Axis.horizontal,
  });

  final List<UiStep> steps;
  final int currentStep;
  final ValueChanged<int>? onStepTapped;
  final Axis orientation;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Step indicators
        if (orientation == Axis.horizontal)
          Row(
            children: [
              for (int i = 0; i < steps.length; i++) ...[
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: i <= currentStep ? colors.primary : colors.border,
                    ),
                  ),
                _StepIndicator(
                  index: i,
                  step: steps[i],
                  isActive: i == currentStep,
                  isCompleted: i < currentStep,
                  onTap: onStepTapped != null ? () => onStepTapped!(i) : null,
                  theme: theme,
                ),
              ],
            ],
          ),
        // Current step content
        if (currentStep >= 0 && currentStep < steps.length && steps[currentStep].content != null)
          Padding(
            padding: EdgeInsets.only(top: spacing.lg),
            child: steps[currentStep].content!,
          ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.index,
    required this.step,
    required this.isActive,
    required this.isCompleted,
    this.onTap,
    required this.theme,
  });

  final int index;
  final UiStep step;
  final bool isActive;
  final bool isCompleted;
  final VoidCallback? onTap;
  final UiThemeData theme;

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final Color circleColor;
    final Color textColor;
    if (step.state == UiStepState.error) {
      circleColor = colors.error;
      textColor = colors.onError;
    } else if (isCompleted || isActive) {
      circleColor = colors.primary;
      textColor = colors.onPrimary;
    } else {
      circleColor = colors.border;
      textColor = colors.onSurface;
    }

    List<BoxShadow>? glow;
    if (isActive && theme.useGlow && colors.glow != null) {
      glow = [BoxShadow(color: colors.glow!.withValues(alpha: 0.3), blurRadius: 10)];
    }

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: theme.animationDuration,
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
                boxShadow: glow,
              ),
              child: Center(
                child: isCompleted
                    ? Icon(const IconData(0xe156, fontFamily: 'MaterialIcons'), size: 18, color: textColor)
                    : Text('${index + 1}', style: typo.labelMedium.copyWith(color: textColor)),
              ),
            ),
            SizedBox(height: spacing.xs),
            Text(
              step.title,
              style: typo.labelSmall.copyWith(
                color: isActive ? colors.primary : colors.onSurface.withValues(alpha: 0.6),
                fontWeight: isActive ? FontWeight.w600 : null,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
