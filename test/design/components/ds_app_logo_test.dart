import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/design/components/ds_app_logo.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

SvgPicture _svg(WidgetTester tester) {
  return tester.widget<SvgPicture>(find.byType(SvgPicture));
}

void main() {
  group('DSAppLogo', () {
    testWidgets('renders the Klozy wordmark from the vector asset', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const DSAppLogo()));

      expect(find.byType(SvgPicture), findsOneWidget);
      final SvgAssetLoader loader = _svg(tester).bytesLoader as SvgAssetLoader;
      expect(loader.assetName, 'assets/svg/logo_klozy.svg');
    });

    testWidgets('sizes the wordmark by the provided height', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const DSAppLogo(size: 64)));

      expect(_svg(tester).height, 64);
    });

    testWidgets('defaults to a height of 44', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const DSAppLogo()));

      expect(_svg(tester).height, 44);
    });

    testWidgets('scales with contain to preserve the aspect ratio', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const DSAppLogo()));

      expect(_svg(tester).fit, BoxFit.contain);
    });
  });
}
