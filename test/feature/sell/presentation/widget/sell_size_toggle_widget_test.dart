import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/design/components/ds_selectable_chip.dart';
import 'package:klozy/src/feature/sell/domain/entity/size_system.dart';
import 'package:klozy/src/feature/sell/presentation/widget/sell_size_toggle_widget.dart';

import '../../../../support/ds_harness.dart';

void main() {
  setUpAll(disableDsFonts);

  Widget buildWidget({
    required SizeSystem current,
    required void Function(SizeSystem) onToggle,
  }) {
    return dsWrap(
      SellSizeToggleWidget(current: current, onToggle: onToggle),
      wrapInScaffold: true,
    );
  }

  testWidgets('renders EU and US chips', (tester) async {
    await tester.pumpWidget(
      buildWidget(current: SizeSystem.eu, onToggle: (_) {}),
    );
    await tester.pump();
    expect(find.text('EU'), findsOneWidget);
    expect(find.text('US'), findsOneWidget);
    expect(find.byType(DSSelectableChip), findsNWidgets(2));
  });

  testWidgets('EU chip is selected when current is eu', (tester) async {
    await tester.pumpWidget(
      buildWidget(current: SizeSystem.eu, onToggle: (_) {}),
    );
    await tester.pump();

    final chips = tester.widgetList<DSSelectableChip>(
      find.byType(DSSelectableChip),
    );
    final euChip = chips.firstWhere((c) => c.label == 'EU');
    final usChip = chips.firstWhere((c) => c.label == 'US');
    expect(euChip.selected, isTrue);
    expect(usChip.selected, isFalse);
  });

  testWidgets('US chip is selected when current is us', (tester) async {
    await tester.pumpWidget(
      buildWidget(current: SizeSystem.us, onToggle: (_) {}),
    );
    await tester.pump();

    final chips = tester.widgetList<DSSelectableChip>(
      find.byType(DSSelectableChip),
    );
    final euChip = chips.firstWhere((c) => c.label == 'EU');
    final usChip = chips.firstWhere((c) => c.label == 'US');
    expect(euChip.selected, isFalse);
    expect(usChip.selected, isTrue);
  });

  testWidgets('tapping EU chip fires onToggle(SizeSystem.eu)', (tester) async {
    SizeSystem? toggled;
    await tester.pumpWidget(
      buildWidget(current: SizeSystem.us, onToggle: (s) => toggled = s),
    );
    await tester.pump();

    await tester.tap(find.text('EU'));
    expect(toggled, SizeSystem.eu);
  });

  testWidgets('tapping US chip fires onToggle(SizeSystem.us)', (tester) async {
    SizeSystem? toggled;
    await tester.pumpWidget(
      buildWidget(current: SizeSystem.eu, onToggle: (s) => toggled = s),
    );
    await tester.pump();

    await tester.tap(find.text('US'));
    expect(toggled, SizeSystem.us);
  });
}
