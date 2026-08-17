import 'package:example/main.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    final font = rootBundle.load('assets/fonts/ShowcaseSans.ttf');
    await (FontLoader('Avenir Next')..addFont(font)).load();
  });

  Future<void> renderShowcase(
    WidgetTester tester, {
    required Size size,
    String? destination,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pump(const Duration(milliseconds: 500));

    if (destination != null) {
      await tester.tap(find.text(destination));
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(tester.takeException(), isNull);
  }

  testWidgets('overview desktop golden', (tester) async {
    await renderShowcase(tester, size: const Size(1440, 1000));
    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_overview_desktop.png'),
    );
  });

  testWidgets('scenarios mobile golden', (tester) async {
    await renderShowcase(
      tester,
      size: const Size(390, 844),
      destination: 'Scenarios',
    );
    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_scenarios_mobile.png'),
    );
  });

  testWidgets('state lab tablet golden', (tester) async {
    await renderShowcase(
      tester,
      size: const Size(820, 1000),
      destination: 'State Lab',
    );
    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_state_lab_tablet.png'),
    );
  });
}
