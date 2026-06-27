import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/presentation/screen/states/chat_list_loading_widget.dart';

void main() {
  testWidgets('renders a non-empty ListView with skeleton rows', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ChatListLoadingWidget())),
    );

    expect(find.byType(ChatListLoadingWidget), findsOneWidget);
    // The widget builds 8 skeleton rows.
    expect(find.byType(ListView), findsOneWidget);
    // At least some rows are visible within the viewport.
    expect(find.byType(Row), findsWidgets);
  });
}
