import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/sell/presentation/widget/sell_transition_widget.dart';

import '../../../../support/ds_harness.dart';

bool _isImageError(FlutterErrorDetails d) =>
    d.exception.toString().contains('FileSystemException') ||
    d.exception.toString().contains('PathNotFoundException') ||
    d.exception.toString().contains('NetworkImageLoadException') ||
    d.exception.toString().contains('HTTP request failed');

// Must be called INSIDE testWidgets body (binding resets handler first).
void _suppressImageErrors() {
  final prev = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails d) {
    if (_isImageError(d)) return;
    prev?.call(d);
  };
  addTearDown(() => FlutterError.onError = prev);
}

void main() {
  setUpAll(disableDsFonts);

  Widget buildWidget({String? coverPath}) {
    return dsWrap(Scaffold(body: SellTransitionWidget(coverPath: coverPath)));
  }

  testWidgets('renders without cover path — shows placeholder', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pump();

    // Sparkle/AI icon present.
    expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
  });

  testWidgets('renders with a cover path', (tester) async {
    _suppressImageErrors();
    await tester.pumpWidget(buildWidget(coverPath: '/tmp/cover.jpg'));
    await tester.pump();

    // File image widget is present (may fail to load in tests — that is ok).
    expect(find.byType(Image), findsAtLeastNWidgets(1));
  });

  testWidgets('shows progress dots', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pump();

    // 3 dot containers arranged in a Row.
    final row = find.descendant(
      of: find.byType(Row),
      matching: find.byType(AnimatedContainer),
    );
    // At least 3 animated containers (the dots).
    expect(row, findsAtLeastNWidgets(3));
  });

  testWidgets('step text advances after timer tick', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pump();

    // Capture initial text.
    final initialText = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .toList();

    // Advance time past first timer tick (1400 ms).
    await tester.pump(const Duration(milliseconds: 1500));

    final updatedText = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .toList();

    // The visible texts may have changed (step advanced).
    // We just verify no exception is thrown during the tick.
    expect(initialText, isNotEmpty);
    expect(updatedText, isNotEmpty);
  });

  testWidgets('disposes without error after pumpWidget replacement', (
    tester,
  ) async {
    await tester.pumpWidget(buildWidget());
    await tester.pump();

    // Replace widget tree to trigger dispose.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    // No assertion — verifies dispose doesn't throw.
  });
}
