import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/settings/presentation/widget/settings_row_widget.dart';

import '../../../../support/ds_harness.dart';

void main() {
  setUpAll(disableDsFonts);

  Widget _pump(SettingsRowWidget widget) =>
      dsWrap(widget, wrapInScaffold: true);

  group('SettingsRowWidget — label', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        _pump(
          const SettingsRowWidget(
            icon: Icons.person_outline,
            label: 'My Label',
          ),
        ),
      );
      await tester.pump();
      expect(find.text('My Label'), findsOneWidget);
    });
  });

  group('SettingsRowWidget — subtitle', () {
    testWidgets('shows subtitle when provided', (tester) async {
      await tester.pumpWidget(
        _pump(
          const SettingsRowWidget(
            icon: Icons.person_outline,
            label: 'Label',
            subtitle: 'Sub info',
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Sub info'), findsOneWidget);
    });

    testWidgets('no subtitle text when omitted', (tester) async {
      await tester.pumpWidget(
        _pump(
          const SettingsRowWidget(icon: Icons.person_outline, label: 'Label'),
        ),
      );
      await tester.pump();
      expect(find.text('Sub info'), findsNothing);
    });
  });

  group('SettingsRowWidget — value', () {
    testWidgets('shows value when provided', (tester) async {
      await tester.pumpWidget(
        _pump(
          const SettingsRowWidget(
            icon: Icons.person_outline,
            label: 'Label',
            value: 'English',
          ),
        ),
      );
      await tester.pump();
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('no value text when omitted', (tester) async {
      await tester.pumpWidget(
        _pump(
          const SettingsRowWidget(icon: Icons.person_outline, label: 'Label'),
        ),
      );
      await tester.pump();
      expect(find.text('English'), findsNothing);
    });
  });

  group('SettingsRowWidget — chevron / onTap', () {
    testWidgets('shows chevron_right when onTap is set and danger=false', (
      tester,
    ) async {
      await tester.pumpWidget(
        _pump(
          SettingsRowWidget(
            icon: Icons.person_outline,
            label: 'Label',
            onTap: () {},
          ),
        ),
      );
      await tester.pump();
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('no chevron when onTap is null', (tester) async {
      await tester.pumpWidget(
        _pump(
          const SettingsRowWidget(icon: Icons.person_outline, label: 'Label'),
        ),
      );
      await tester.pump();
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('no chevron when danger=true even with onTap', (tester) async {
      await tester.pumpWidget(
        _pump(
          SettingsRowWidget(
            icon: Icons.delete_outline,
            label: 'Delete',
            onTap: () {},
            danger: true,
          ),
        ),
      );
      await tester.pump();
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('onTap callback fires when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _pump(
          SettingsRowWidget(
            icon: Icons.person_outline,
            label: 'Label',
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byType(InkWell).first);
      expect(tapped, isTrue);
    });
  });

  group('SettingsRowWidget — trailing', () {
    testWidgets('renders trailing widget when provided', (tester) async {
      await tester.pumpWidget(
        _pump(
          SettingsRowWidget(
            icon: Icons.person_outline,
            label: 'Label',
            onTap: () {},
            trailing: const Icon(Icons.toggle_on, key: Key('trail')),
          ),
        ),
      );
      await tester.pump();
      expect(find.byKey(const Key('trail')), findsOneWidget);
      // trailing replaces chevron
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });
  });

  group('SettingsRowWidget — danger', () {
    testWidgets('danger flag renders the row without error', (tester) async {
      await tester.pumpWidget(
        _pump(
          const SettingsRowWidget(
            icon: Icons.delete_outline,
            label: 'Delete account',
            danger: true,
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Delete account'), findsOneWidget);
    });
  });
}
