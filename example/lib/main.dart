import 'package:flutter/widgets.dart';
import 'package:flutter_ui_collection/flutter_ui_collection.dart';

void main() {
  runApp(const ShowcaseApp());
}

class ShowcaseApp extends StatefulWidget {
  const ShowcaseApp({super.key});

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  // All themes grouped by preset: [dark, light] pairs
  static final _presets = <String, List<UiThemeData>>{
    'Neon': [NeonTheme.dark, NeonTheme.light],
    'Glass': [GlassTheme.dark, GlassTheme.light],
    'Minimal': [MinimalTheme.dark, MinimalTheme.light],
    'Cyberpunk': [CyberpunkTheme.dark, CyberpunkTheme.light],
    'Retro': [RetroTheme.dark, RetroTheme.light],
    'Aurora': [AuroraTheme.dark, AuroraTheme.light],
    'Terminal': [TerminalTheme.dark, TerminalTheme.amber],
    'Pastel': [PastelTheme.dark, PastelTheme.light],
  };

  // Initial state — overridable for screenshot capture.
  String _preset = const String.fromEnvironment('PRESET', defaultValue: 'Neon');
  bool _isDark = !const bool.fromEnvironment('LIGHT');
  int _pageIndex = const int.fromEnvironment('PAGE');
  bool _largeText = false;
  bool _reducedMotion = false;
  int _labState = 0;

  UiThemeData get _currentTheme {
    final pair = _presets[_preset]!;
    final theme = _isDark ? pair[0] : pair[1];
    return _reducedMotion
        ? theme.copyWith(animationDuration: Duration.zero)
        : theme;
  }

  void _nextPreset() {
    final keys = _presets.keys.toList();
    final i = (keys.indexOf(_preset) + 1) % keys.length;
    setState(() => _preset = keys[i]);
  }

  void _toggleDarkLight() {
    setState(() => _isDark = !_isDark);
  }

  @override
  Widget build(BuildContext context) {
    return UiApp(
      theme: _currentTheme,
      title: 'Flutter UI Collection',
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(_largeText ? 1.3 : 1)),
          child: UiScaffold(
            appBar: UiAppBar(
              title: const Text('UI Collection'),
              actions: [
                UiIconButton(
                  icon: _isDark ? UiIcons.lightMode : UiIcons.darkMode,
                  tooltip: _isDark
                      ? 'Use light appearance'
                      : 'Use dark appearance',
                  onPressed: _toggleDarkLight,
                ),
                Builder(
                  builder: (context) => MediaQuery.sizeOf(context).width < 520
                      ? UiIconButton(
                          icon: UiIcons.palette,
                          tooltip: 'Next design preset: $_preset selected',
                          onPressed: _nextPreset,
                        )
                      : UiButton(
                          label: _preset,
                          variant: UiButtonVariant.outlined,
                          onPressed: _nextPreset,
                        ),
                ),
              ],
            ),
            bottomBar: UiBottomNav(
              items: const [
                UiBottomNavItem(icon: UiIcons.home, label: 'Overview'),
                UiBottomNavItem(icon: UiIcons.dashboard, label: 'Scenarios'),
                UiBottomNavItem(icon: UiIcons.palette, label: 'State Lab'),
              ],
              selectedIndex: _pageIndex,
              onChanged: (i) => setState(() => _pageIndex = i),
            ),
            body: IndexedStack(
              index: _pageIndex,
              children: [
                _PremiumOverview(
                  presets: _presets,
                  selected: _preset,
                  isDark: _isDark,
                  onSelected: (value) => setState(() => _preset = value),
                ),
                const _ProductScenarios(),
                _StateLab(
                  selectedState: _labState,
                  largeText: _largeText,
                  reducedMotion: _reducedMotion,
                  onStateChanged: (value) => setState(() => _labState = value),
                  onLargeTextChanged: (value) =>
                      setState(() => _largeText = value),
                  onReducedMotionChanged: (value) =>
                      setState(() => _reducedMotion = value),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumOverview extends StatelessWidget {
  const _PremiumOverview({
    required this.presets,
    required this.selected,
    required this.isDark,
    required this.onSelected,
  });

  final Map<String, List<UiThemeData>> presets;
  final String selected;
  final bool isDark;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final spacing = theme.spacing;
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      padding: spacing.paddingMd,
      child: UiResponsiveBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(spacing.xl),
              decoration: BoxDecoration(
                color: colors.resolvedSurfaceRaised,
                borderRadius: theme.components.cardBorderRadius,
                boxShadow: theme.surfaceShadows(emphasized: true),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'One collection. Eight unmistakable voices.',
                      style: theme.typography.displaySmall,
                    ),
                    SizedBox(height: spacing.sm),
                    Text(
                      'Production-ready controls, responsive product modules, and accessible interaction patterns—without the default Flutter visual language.',
                      style: theme.typography.bodyLarge.copyWith(
                        color: colors.resolvedOnSurfaceMuted,
                      ),
                    ),
                    SizedBox(height: spacing.lg),
                    Wrap(
                      spacing: spacing.sm,
                      runSpacing: spacing.sm,
                      children: [
                        UiButton(label: 'Explore scenarios', onPressed: () {}),
                        UiButton(
                          label: 'Inspect states',
                          variant: UiButtonVariant.ghost,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: spacing.xl),
            Text('Choose a design grammar', style: theme.typography.titleLarge),
            SizedBox(height: spacing.xs),
            Text(
              'The previews change geometry, type, depth, icons, and motion—not only color.',
              style: theme.typography.bodyMedium.copyWith(
                color: colors.resolvedOnSurfaceMuted,
              ),
            ),
            SizedBox(height: spacing.sm),
            UiThemeSelector(
              themes: [
                for (final entry in presets.entries)
                  UiThemePreview(
                    name: entry.key,
                    data: isDark ? entry.value.first : entry.value.last,
                  ),
              ],
              selectedTheme: selected,
              onChanged: onSelected,
              crossAxisCount: 4,
            ),
            SizedBox(height: spacing.xl),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 760;
                final cards = [
                  const UiStatCard(
                    label: 'Core components',
                    value: '89',
                    trend: UiStatCardTrend.up,
                    trendValue: 'keyboard ready',
                  ),
                  const UiStatCard(
                    label: 'Product modules',
                    value: '6',
                    trend: UiStatCardTrend.up,
                    trendValue: 'responsive',
                  ),
                  const UiStatCard(
                    label: 'Preset voices',
                    value: '8',
                    trend: UiStatCardTrend.up,
                    trendValue: 'light + dark',
                  ),
                ];
                return wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < cards.length; i++) ...[
                            if (i > 0) SizedBox(width: spacing.sm),
                            Expanded(child: cards[i]),
                          ],
                        ],
                      )
                    : Column(
                        children: [
                          for (var i = 0; i < cards.length; i++) ...[
                            if (i > 0) SizedBox(height: spacing.sm),
                            cards[i],
                          ],
                        ],
                      );
              },
            ),
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}

class _ProductScenarios extends StatelessWidget {
  const _ProductScenarios();

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final spacing = theme.spacing;
    final colors = theme.colorScheme;
    final user = const UiSocialUser(
      id: 'maya',
      name: 'Maya Rodriguez',
      username: 'maya.builds',
      isVerified: true,
    );

    final dashboard = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Today at a glance', style: theme.typography.titleLarge),
        SizedBox(height: spacing.sm),
        const UiStatCard(
          label: 'Recurring revenue',
          value: '€48.240',
          trend: UiStatCardTrend.up,
          trendValue: '+8.5% this month',
          sparklineData: [20, 28, 25, 41, 38, 54, 62],
        ),
        SizedBox(height: spacing.sm),
        const UiLineChart(
          height: 220,
          filled: true,
          showDots: true,
          data: [
            UiLineChartData(
              label: 'Revenue',
              points: [18, 26, 22, 38, 34, 49, 57],
            ),
          ],
        ),
      ],
    );

    final activity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Customer pulse', style: theme.typography.titleLarge),
        SizedBox(height: spacing.sm),
        UiPostCard(
          post: UiPost(
            id: 'launch',
            author: user,
            content:
                'The new checkout flow is live. Faster on mobile, calmer on desktop, and fully keyboard accessible. #productdesign',
            likeCount: 284,
            commentCount: 36,
            shareCount: 18,
            isLiked: true,
            timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
          ),
          onLike: () {},
          onComment: () {},
          onShare: () {},
        ),
        SizedBox(height: spacing.sm),
        UiProductCard(
          product: const UiProduct(
            id: 'studio-headphones',
            name: 'Studio Wireless Headphones',
            description: 'Low-latency audio with 40-hour battery life.',
            price: 249,
            salePrice: 199,
            rating: 4.8,
            reviewCount: 342,
            badges: ['EDITOR PICK'],
          ),
          imageHeight: 150,
          onAddToCart: () {},
        ),
      ],
    );

    return SingleChildScrollView(
      padding: spacing.paddingMd,
      child: UiResponsiveBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Real product scenarios',
              style: theme.typography.displaySmall,
            ),
            SizedBox(height: spacing.xs),
            Text(
              'Resize the window: the same content moves from a focused mobile flow to a balanced tablet stack and a two-column desktop workspace.',
              style: theme.typography.bodyLarge.copyWith(
                color: colors.resolvedOnSurfaceMuted,
              ),
            ),
            SizedBox(height: spacing.lg),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 900) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: dashboard),
                      SizedBox(width: spacing.lg),
                      Expanded(flex: 4, child: activity),
                    ],
                  );
                }
                return Column(
                  children: [
                    dashboard,
                    SizedBox(height: spacing.xl),
                    activity,
                  ],
                );
              },
            ),
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}

class _StateLab extends StatelessWidget {
  const _StateLab({
    required this.selectedState,
    required this.largeText,
    required this.reducedMotion,
    required this.onStateChanged,
    required this.onLargeTextChanged,
    required this.onReducedMotionChanged,
  });

  final int selectedState;
  final bool largeText;
  final bool reducedMotion;
  final ValueChanged<int> onStateChanged;
  final ValueChanged<bool> onLargeTextChanged;
  final ValueChanged<bool> onReducedMotionChanged;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final spacing = theme.spacing;
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      padding: spacing.paddingMd,
      child: UiResponsiveBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Accessibility & state lab',
              style: theme.typography.displaySmall,
            ),
            SizedBox(height: spacing.xs),
            Text(
              'Stress the interface before users do. Every control remains keyboard reachable and every state explains the next action.',
              style: theme.typography.bodyLarge.copyWith(
                color: colors.resolvedOnSurfaceMuted,
              ),
            ),
            SizedBox(height: spacing.lg),
            UiSettingsSection(
              title: 'Accessibility simulation',
              children: [
                _LabToggleRow(
                  label: 'Large text',
                  description: 'Render the showcase at 130% text scale.',
                  value: largeText,
                  onChanged: onLargeTextChanged,
                ),
                _LabToggleRow(
                  label: 'Reduce motion',
                  description: 'Disable preset transition durations.',
                  value: reducedMotion,
                  onChanged: onReducedMotionChanged,
                ),
              ],
            ),
            SizedBox(height: spacing.lg),
            Text('Component state', style: theme.typography.titleLarge),
            SizedBox(height: spacing.sm),
            UiSegmentedControl(
              segments: const ['Ready', 'Loading', 'Error', 'Empty'],
              selectedIndex: selectedState,
              onChanged: onStateChanged,
            ),
            SizedBox(height: spacing.md),
            AnimatedSwitcher(
              duration: theme.animationDuration,
              switchInCurve: theme.animationCurve,
              child: _LabStateCanvas(state: selectedState),
            ),
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}

class _LabToggleRow extends StatelessWidget {
  const _LabToggleRow({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    return Padding(
      padding: EdgeInsets.all(theme.spacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.typography.titleSmall),
                SizedBox(height: theme.spacing.xs),
                Text(
                  description,
                  style: theme.typography.bodySmall.copyWith(
                    color: theme.colorScheme.resolvedOnSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: theme.spacing.md),
          UiToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _LabStateCanvas extends StatelessWidget {
  const _LabStateCanvas({required this.state});

  final int state;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final spacing = theme.spacing;

    return UiCard(
      key: ValueKey(state),
      child: switch (state) {
        1 => Column(
          children: [
            const UiSkeleton(width: double.infinity, height: 28),
            SizedBox(height: spacing.sm),
            const UiSkeleton(width: double.infinity, height: 96),
            SizedBox(height: spacing.sm),
            const UiSkeleton(width: 180, height: 44),
          ],
        ),
        2 => UiAlert(
          type: UiAlertType.error,
          title: 'We could not sync this workspace',
          message:
              'Check your connection, then try again. Your local changes are safe.',
          action: UiButton(
            label: 'Try again',
            variant: UiButtonVariant.outlined,
            onPressed: () {},
          ),
        ),
        3 => UiEmptyState(
          icon: UiIcons.folder,
          title: 'No projects here yet',
          description:
              'Create a project or import one from your existing workspace.',
          action: UiButton(label: 'Create project', onPressed: () {}),
        ),
        _ => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Workspace ready', style: theme.typography.titleLarge),
            SizedBox(height: spacing.xs),
            Text(
              'All systems are healthy. You can continue where you left off.',
              style: theme.typography.bodyMedium,
            ),
            SizedBox(height: spacing.md),
            Wrap(
              spacing: spacing.sm,
              runSpacing: spacing.sm,
              children: [
                UiButton(label: 'Open workspace', onPressed: () {}),
                UiButton(
                  label: 'View activity',
                  variant: UiButtonVariant.ghost,
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      },
    );
  }
}
