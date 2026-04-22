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
  static final _themes = [
    NeonTheme.dark,
    NeonTheme.light,
    GlassTheme.dark,
    MinimalTheme.dark,
    MinimalTheme.light,
    CyberpunkTheme.dark,
    RetroTheme.dark,
    AuroraTheme.dark,
    TerminalTheme.dark,
    PastelTheme.light,
  ];

  int _themeIndex = 0;
  int _pageIndex = 0;

  void _nextTheme() {
    setState(() => _themeIndex = (_themeIndex + 1) % _themes.length);
  }

  @override
  Widget build(BuildContext context) {
    return UiApp(
      theme: _themes[_themeIndex],
      title: 'Flutter UI Collection',
      home: UiScaffold(
        appBar: UiAppBar(
          title: const Text('Flutter UI Collection'),
          actions: [
            GestureDetector(
              onTap: _nextTheme,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Builder(builder: (context) {
                  final t = UiTheme.of(context);
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: t.spacing.sm,
                      vertical: t.spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: t.spacing.radiusFull,
                      border: Border.all(color: t.colorScheme.border),
                    ),
                    child: Text(
                      t.name,
                      style: t.typography.labelSmall.copyWith(
                        color: t.colorScheme.primary,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
        bottomBar: UiBottomNav(
          items: const [
            UiBottomNavItem(icon: UiIcons.dashboard, label: 'Components'),
            UiBottomNavItem(icon: UiIcons.palette, label: 'Effects'),
            UiBottomNavItem(icon: UiIcons.code, label: 'Modules'),
          ],
          selectedIndex: _pageIndex,
          onChanged: (i) => setState(() => _pageIndex = i),
        ),
        body: IndexedStack(
          index: _pageIndex,
          children: const [
            _ComponentsPage(),
            _EffectsPage(),
            _ModulesPage(),
          ],
        ),
      ),
    );
  }
}

// ─── Components Page ───

class _ComponentsPage extends StatefulWidget {
  const _ComponentsPage();

  @override
  State<_ComponentsPage> createState() => _ComponentsPageState();
}

class _ComponentsPageState extends State<_ComponentsPage> {
  bool _toggle = false;
  bool _checkbox = false;
  String _radio = 'a';
  double _slider = 0.5;
  double _rating = 3.5;
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final t = UiTheme.of(context);
    final sp = t.spacing;

    return SingleChildScrollView(
      padding: sp.paddingMd,
      child: UiResponsiveBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Buttons ──
            _SectionTitle('Buttons'),
            Wrap(spacing: sp.sm, runSpacing: sp.sm, children: [
              UiButton(label: 'Filled', onPressed: () {}),
              UiButton(
                  label: 'Outlined',
                  variant: UiButtonVariant.outlined,
                  onPressed: () {}),
              UiButton(
                  label: 'Ghost',
                  variant: UiButtonVariant.ghost,
                  onPressed: () {}),
              UiButton(
                  label: 'Glow',
                  variant: UiButtonVariant.glow,
                  onPressed: () {}),
              const UiButton(label: 'Disabled'),
              UiIconButton(icon: UiIcons.settings, onPressed: () {}),
            ]),
            SizedBox(height: sp.lg),

            // ── Inputs ──
            _SectionTitle('Inputs'),
            const UiTextField(
              label: 'Email',
              placeholder: 'you@example.com',
              prefixIcon: UiIcons.email,
            ),
            SizedBox(height: sp.sm),
            const UiTextField(
              label: 'Password',
              placeholder: 'Enter password',
              obscureText: true,
              prefixIcon: UiIcons.lock,
            ),
            SizedBox(height: sp.sm),
            const UiSearchBar(placeholder: 'Search...'),
            SizedBox(height: sp.lg),

            // ── Toggle / Checkbox / Radio ──
            _SectionTitle('Controls'),
            Row(children: [
              UiToggle(
                  value: _toggle,
                  onChanged: (v) => setState(() => _toggle = v)),
              SizedBox(width: sp.md),
              UiCheckbox(
                  value: _checkbox,
                  onChanged: (v) => setState(() => _checkbox = v ?? false),
                  label: 'Accept terms'),
            ]),
            SizedBox(height: sp.sm),
            Row(children: [
              UiRadio<String>(
                  value: 'a',
                  groupValue: _radio,
                  onChanged: (v) => setState(() => _radio = v),
                  label: 'Option A'),
              SizedBox(width: sp.md),
              UiRadio<String>(
                  value: 'b',
                  groupValue: _radio,
                  onChanged: (v) => setState(() => _radio = v),
                  label: 'Option B'),
            ]),
            SizedBox(height: sp.sm),
            UiSlider(
              value: _slider,
              onChanged: (v) => setState(() => _slider = v),
              label: 'Volume',
              showValue: true,
            ),
            SizedBox(height: sp.sm),
            UiRating(
              value: _rating,
              onChanged: (v) => setState(() => _rating = v),
            ),
            SizedBox(height: sp.lg),

            // ── Badges & Chips ──
            _SectionTitle('Badges & Chips'),
            Wrap(spacing: sp.sm, runSpacing: sp.sm, children: const [
              UiBadge(label: 'NEW', type: UiBadgeType.primary),
              UiBadge(label: 'SALE', type: UiBadgeType.error),
              UiBadge(
                  label: 'OK',
                  type: UiBadgeType.success,
                  size: UiBadgeSize.small),
              UiChip(label: 'Flutter', selected: true),
              UiChip(label: 'Dart'),
            ]),
            SizedBox(height: sp.lg),

            // ── Cards ──
            _SectionTitle('Cards'),
            UiCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Standard Card',
                      style: t.typography.titleMedium),
                  SizedBox(height: sp.xs),
                  Text('This card adapts to any theme automatically.',
                      style: t.typography.bodyMedium),
                ],
              ),
            ),
            SizedBox(height: sp.sm),
            UiCard(
              blur: true,
              child: Text('Glass Card (blur effect)',
                  style: t.typography.bodyMedium),
            ),
            SizedBox(height: sp.lg),

            // ── Avatars ──
            _SectionTitle('Avatars'),
            Row(children: [
              const UiAvatar(
                  initials: 'TL',
                  size: UiAvatarSize.small,
                  status: UiAvatarStatus.online),
              SizedBox(width: sp.sm),
              const UiAvatar(initials: 'AB', status: UiAvatarStatus.busy),
              SizedBox(width: sp.sm),
              const UiAvatar(
                  initials: 'XY',
                  size: UiAvatarSize.large,
                  status: UiAvatarStatus.away),
              SizedBox(width: sp.md),
              const UiAvatarGroup(
                maxVisible: 3,
                avatars: [
                  UiAvatar(initials: 'A', size: UiAvatarSize.small),
                  UiAvatar(initials: 'B', size: UiAvatarSize.small),
                  UiAvatar(initials: 'C', size: UiAvatarSize.small),
                  UiAvatar(initials: 'D', size: UiAvatarSize.small),
                ],
              ),
            ]),
            SizedBox(height: sp.lg),

            // ── Progress ──
            _SectionTitle('Progress'),
            const UiProgressBar(value: 0.7, showLabel: true),
            SizedBox(height: sp.sm),
            Row(children: [
              const UiProgressCircle(value: 0.65, showLabel: true, size: 56),
              SizedBox(width: sp.md),
              const UiProgressCircle(value: 0.9, showLabel: true, size: 56),
            ]),
            SizedBox(height: sp.lg),

            // ── TabBar ──
            _SectionTitle('Navigation'),
            UiTabBar(
              tabs: const [
                UiTab(label: 'Home'),
                UiTab(label: 'Search'),
                UiTab(label: 'Profile'),
              ],
              selectedIndex: _tabIndex,
              onChanged: (i) => setState(() => _tabIndex = i),
            ),
            SizedBox(height: sp.sm),
            UiSegmentedControl(
              segments: const ['Day', 'Week', 'Month'],
              selectedIndex: _tabIndex,
              onChanged: (i) => setState(() => _tabIndex = i),
            ),
            SizedBox(height: sp.lg),

            // ── Alert ──
            _SectionTitle('Alerts'),
            const UiAlert(
              type: UiAlertType.info,
              title: 'Info',
              message: 'This is an informational alert.',
            ),
            SizedBox(height: sp.sm),
            const UiAlert(
              type: UiAlertType.success,
              message: 'Operation completed successfully!',
            ),
            SizedBox(height: sp.lg),

            // ── Timeline ──
            _SectionTitle('Timeline'),
            const UiTimeline(items: [
              UiTimelineItem(title: 'Order placed', subtitle: '2h ago'),
              UiTimelineItem(title: 'Processing', subtitle: '1h ago'),
              UiTimelineItem(title: 'Shipped', subtitle: 'Just now'),
            ]),
            SizedBox(height: sp.lg),

            // ── Accordion ──
            _SectionTitle('Accordion'),
            const UiAccordion(sections: [
              UiAccordionSection(
                title: 'What is Flutter UI Collection?',
                content: Text(
                    'A complete Material-free UI framework for Flutter with 89 components, 6 modules, and 8 design presets.'),
              ),
              UiAccordionSection(
                title: 'How do I change themes?',
                content: Text(
                    'Wrap your app with UiApp and pass a theme. Tap the theme name in the app bar above to see it live!'),
              ),
            ]),
            SizedBox(height: sp.lg),

            // ── Code Block ──
            _SectionTitle('Code Block'),
            const UiCodeBlock(
              language: 'dart',
              showLineNumbers: true,
              code:
                  'void main() {\n  runApp(UiApp(\n    theme: NeonTheme.dark,\n    home: MyApp(),\n  ));\n}',
            ),
            SizedBox(height: sp.lg),

            // ── Stat ──
            _SectionTitle('Stats'),
            const Row(children: [
              Expanded(
                  child: UiStat(
                      label: 'Users',
                      value: '12,345',
                      trend: UiStatTrend.up,
                      trendText: '+12%')),
              Expanded(
                  child: UiStat(
                      label: 'Revenue',
                      value: '\$48.2K',
                      trend: UiStatTrend.up,
                      trendText: '+8.5%')),
              Expanded(
                  child: UiStat(
                      label: 'Bounce',
                      value: '34%',
                      trend: UiStatTrend.down,
                      trendText: '-2.1%')),
            ]),
            SizedBox(height: sp.xxl),
          ],
        ),
      ),
    );
  }
}

// ─── Effects Page ───

class _EffectsPage extends StatelessWidget {
  const _EffectsPage();

  @override
  Widget build(BuildContext context) {
    final t = UiTheme.of(context);
    final sp = t.spacing;

    return SingleChildScrollView(
      padding: sp.paddingMd,
      child: UiResponsiveBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('Gradient Text'),
            const UiGradientText('Hello World'),
            SizedBox(height: sp.lg),

            _SectionTitle('Shimmer Text'),
            const UiShimmerText('Loading data...'),
            SizedBox(height: sp.lg),

            _SectionTitle('Typewriter'),
            const UiTypewriter(
              text: 'Welcome to the future of Flutter UI.',
              speed: Duration(milliseconds: 60),
            ),
            SizedBox(height: sp.lg),

            _SectionTitle('Count Up'),
            const Row(children: [
              UiCountUp(end: 9847, prefix: '\$', duration: Duration(seconds: 2)),
            ]),
            SizedBox(height: sp.lg),

            _SectionTitle('Pulse'),
            UiPulse(
              child: UiBadge(
                  label: 'LIVE',
                  type: UiBadgeType.error,
                  size: UiBadgeSize.large),
            ),
            SizedBox(height: sp.lg),

            _SectionTitle('Glow Container'),
            UiGlowContainer(
              child: UiCard(
                child: Text('Premium Content',
                    style: t.typography.titleMedium),
              ),
            ),
            SizedBox(height: sp.lg),

            _SectionTitle('Staggered Animation'),
            UiStagger(
              children: [
                UiCard(child: Text('First item', style: t.typography.bodyMedium)),
                UiCard(child: Text('Second item', style: t.typography.bodyMedium)),
                UiCard(child: Text('Third item', style: t.typography.bodyMedium)),
              ],
            ),
            SizedBox(height: sp.lg),

            _SectionTitle('Keyboard Shortcuts'),
            const Row(children: [
              UiKbd(keys: ['Ctrl', 'K']),
              SizedBox(width: 16),
              UiKbd(keys: ['Cmd', 'Shift', 'P']),
            ]),
            SizedBox(height: sp.xxl),
          ],
        ),
      ),
    );
  }
}

// ─── Modules Page ───

class _ModulesPage extends StatelessWidget {
  const _ModulesPage();

  @override
  Widget build(BuildContext context) {
    final t = UiTheme.of(context);
    final sp = t.spacing;

    return SingleChildScrollView(
      padding: sp.paddingMd,
      child: UiResponsiveBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('Chat Module'),
            SizedBox(
              height: 300,
              child: _ChatDemo(),
            ),
            SizedBox(height: sp.lg),

            _SectionTitle('Dashboard Module'),
            const SizedBox(
              height: 200,
              child: UiBarChart(data: [
                UiBarChartData(label: 'Jan', value: 40),
                UiBarChartData(label: 'Feb', value: 65),
                UiBarChartData(label: 'Mar', value: 55),
                UiBarChartData(label: 'Apr', value: 80),
                UiBarChartData(label: 'May', value: 72),
              ]),
            ),
            SizedBox(height: sp.lg),

            _SectionTitle('E-Commerce Module'),
            const UiPriceDisplay(
              price: 29.99,
              originalPrice: 49.99,
              currency: '\$',
            ),
            SizedBox(height: sp.sm),
            const UiCartSummary(
              subtotal: 59.98,
              shipping: 5.99,
              tax: 4.80,
              total: 70.77,
              currency: '\$',
              itemCount: 2,
            ),
            SizedBox(height: sp.lg),

            _SectionTitle('Social Module'),
            UiSocialActionBar(
              likeCount: 42,
              commentCount: 7,
              shareCount: 3,
              isLiked: true,
              isBookmarked: false,
              onLike: () {},
              onComment: () {},
              onShare: () {},
              onBookmark: () {},
            ),
            SizedBox(height: sp.lg),

            _SectionTitle('Settings Module'),
            UiSettingsSection(
              title: 'Preferences',
              children: [
                UiSettingsToggle(
                  title: 'Dark Mode',
                  subtitle: 'Use dark theme',
                  value: true,
                  onChanged: (_) {},
                ),
                UiSettingsNavigation(
                  title: 'Language',
                  subtitle: 'English',
                  onTap: () {},
                ),
                UiSettingsNavigation(
                  title: 'Notifications',
                  badge: '3',
                  onTap: () {},
                ),
              ],
            ),
            SizedBox(height: sp.xxl),
          ],
        ),
      ),
    );
  }
}

// ─── Chat Demo ───

class _ChatDemo extends StatefulWidget {
  @override
  State<_ChatDemo> createState() => _ChatDemoState();
}

class _ChatDemoState extends State<_ChatDemo> {
  late final UiChatController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = UiChatController(
      currentUser: const UiChatUser(id: 'me', name: 'You'),
      messages: [
        UiChatMessage(
          id: '1',
          roomId: 'demo',
          sender: const UiChatUser(id: 'other', name: 'Alice'),
          content: 'Hey! Have you tried the new UI framework?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        UiChatMessage(
          id: '2',
          roomId: 'demo',
          sender: const UiChatUser(id: 'me', name: 'You'),
          content: 'Yes! It looks amazing with the Neon theme.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
          status: UiMessageStatus.read,
        ),
        UiChatMessage(
          id: '3',
          roomId: 'demo',
          sender: const UiChatUser(id: 'other', name: 'Alice'),
          content: 'Try switching themes with the button in the top bar!',
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: UiTheme.of(context).spacing.radiusMd,
      child: UiChatRoomView(
        controller: _ctrl,
        currentUserId: 'me',
        roomName: 'Demo Chat',
        showAppBar: false,
        onSend: (text) {
          _ctrl.addMessage(UiChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            roomId: 'demo',
            sender: const UiChatUser(id: 'me', name: 'You'),
            content: text,
            timestamp: DateTime.now(),
            status: UiMessageStatus.sent,
          ));
        },
      ),
    );
  }
}

// ─── Helper ───

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    final t = UiTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: t.spacing.sm),
      child: Text(title, style: t.typography.headlineSmall),
    );
  }
}
