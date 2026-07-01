import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/core/network/base_url/base_url.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/feature/settings/presentation/screen/legal_doc_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../../../support/ds_harness.dart';

class _FakeBaseUrl implements BaseUrl {
  @override
  String get baseUrl => 'https://api.test/';
}

class _MockStackRouter extends Mock implements StackRouter {}

/// Minimal test platform so [InAppWebView] can build without a real native
/// implementation. It renders nothing and never fires load callbacks, so the
/// page stays in its loading state — which is all these widget tests need.
class _FakeInAppWebViewPlatform extends InAppWebViewPlatform
    with MockPlatformInterfaceMixin {
  @override
  PlatformInAppWebViewWidget createPlatformInAppWebViewWidget(
    PlatformInAppWebViewWidgetCreationParams params,
  ) => _FakeInAppWebViewWidget(params);
}

class _FakeInAppWebViewWidget extends PlatformInAppWebViewWidget
    with MockPlatformInterfaceMixin {
  _FakeInAppWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();

  @override
  T controllerFromPlatform<T>(PlatformInAppWebViewController controller) =>
      throw UnimplementedError();

  @override
  void dispose() {}
}

void main() {
  setUpAll(() {
    disableDsFonts();
    InAppWebViewPlatform.instance = _FakeInAppWebViewPlatform();
  });

  late _MockStackRouter router;

  setUp(() {
    router = _MockStackRouter();
    when(() => router.maybePop<Object?>()).thenAnswer((_) async => true);

    if (locator.isRegistered<BaseUrl>()) {
      locator.unregister<BaseUrl>();
    }
    locator.registerSingleton<BaseUrl>(_FakeBaseUrl());
  });

  tearDown(() {
    if (locator.isRegistered<BaseUrl>()) {
      locator.unregister<BaseUrl>();
    }
  });

  Widget pump({String docKey = 'tos'}) {
    return dsWrapRouted(LegalDocPage(docKey: docKey), router: router);
  }

  group('LegalDocPage — loading state', () {
    testWidgets('shows DSLoader until the WebView finishes loading', (
      tester,
    ) async {
      await tester.pumpWidget(pump());
      // Single frame only: DSLoader is an infinite animation and `onLoadStop`
      // never fires in the test environment, so the loader stays up.
      await tester.pump();

      expect(find.byType(DSLoader), findsOneWidget);
    });
  });

  group('LegalDocPage — WebView', () {
    testWidgets('loads the legal HTML URL built from BaseUrl + docKey', (
      tester,
    ) async {
      await tester.pumpWidget(pump(docKey: 'privacy'));
      await tester.pump();

      final InAppWebView webView = tester.widget<InAppWebView>(
        find.byType(InAppWebView),
      );
      expect(
        webView.platform.params.initialUrlRequest?.url.toString(),
        'https://api.test/v1/legal/privacy/html',
      );
    });
  });

  group('LegalDocPage — navigation', () {
    testWidgets('back button calls router.maybePop', (tester) async {
      await tester.pumpWidget(pump());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      verify(() => router.maybePop<Object?>()).called(1);
    });
  });
}
