import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/settings/presentation/widget/settings_section_widget.dart';

import '../../../../support/ds_harness.dart';

void main() {
  setUpAll(disableDsFonts);

  group('SettingsSectionWidget', () {
    testWidgets('renders title text uppercased', (tester) async {
      await tester.pumpWidget(
        dsWrap(
          const SettingsSectionWidget(title: 'Profile', children: <Widget>[]),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();
      // The widget calls title.toUpperCase() internally
      expect(find.text('PROFILE'), findsOneWidget);
    });

    testWidgets('renders all children', (tester) async {
      await tester.pumpWidget(
        dsWrap(
          const SettingsSectionWidget(
            title: 'Section',
            children: <Widget>[
              Text('Child One', key: Key('c1')),
              Text('Child Two', key: Key('c2')),
            ],
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();
      expect(find.byKey(const Key('c1')), findsOneWidget);
      expect(find.byKey(const Key('c2')), findsOneWidget);
    });

    testWidgets('works with empty children list', (tester) async {
      await tester.pumpWidget(
        dsWrap(
          const SettingsSectionWidget(title: 'Empty', children: <Widget>[]),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();
      expect(find.text('EMPTY'), findsOneWidget);
    });
  });
}
