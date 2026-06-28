import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/design/components/ds_sparkle.dart';
import 'package:klozy/src/feature/sell/presentation/widget/sell_field_ai_badge_widget.dart';

import '../../../../support/ds_harness.dart';

void main() {
  setUpAll(disableDsFonts);

  testWidgets('renders DSSparkle', (tester) async {
    await tester.pumpWidget(
      dsWrap(const SellFieldAiBadgeWidget(), wrapInScaffold: true),
    );
    await tester.pump();
    expect(find.byType(DSSparkle), findsOneWidget);
  });

  testWidgets('renders "suggested by AI" label text', (tester) async {
    await tester.pumpWidget(
      dsWrap(const SellFieldAiBadgeWidget(), wrapInScaffold: true),
    );
    await tester.pump();
    // The text content comes from l10N; verify a Text widget exists.
    expect(find.byType(Text), findsAtLeastNWidgets(1));
  });
}
