import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/notifications/entity/app_notification.dart';
import 'package:klozy/src/domain/notifications/entity/notification_type.dart';
import 'package:klozy/src/feature/notifications/presentation/widget/notification_row_widget.dart';
import '../../../support/ds_harness.dart';

// ────────────────────────────────────────────────────────────────────────────
// Fixtures
// ────────────────────────────────────────────────────────────────────────────

const _kUnread = AppNotification(
  id: 'n1',
  type: NotificationType.newOrder,
  title: 'New order received',
  body: 'Someone placed an order for your item.',
  read: false,
);

const _kRead = AppNotification(
  id: 'n2',
  type: NotificationType.delivered,
  title: 'Order delivered',
  body: '',
  read: true,
);

// A notification with a timestamp old enough to display a "d ago" label.
final _kWithTime = AppNotification(
  id: 'n3',
  type: NotificationType.newFollower,
  title: 'New follower',
  body: 'Someone started following you.',
  read: false,
  createdAt: DateTime.now().subtract(const Duration(days: 2)),
);

final _kWithHours = AppNotification(
  id: 'n4',
  type: NotificationType.priceDrop,
  title: 'Price drop',
  body: '',
  read: false,
  createdAt: DateTime.now().subtract(const Duration(hours: 3)),
);

final _kWithMinutes = AppNotification(
  id: 'n5',
  type: NotificationType.inDelivery,
  title: 'In delivery',
  body: '',
  read: false,
  createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
);

final _kJustNow = AppNotification(
  id: 'n6',
  type: NotificationType.newReview,
  title: 'New review',
  body: '',
  read: false,
  createdAt: DateTime.now().subtract(const Duration(seconds: 30)),
);

// ────────────────────────────────────────────────────────────────────────────
// Helpers
// ────────────────────────────────────────────────────────────────────────────

Widget _buildRow({
  required AppNotification notification,
  VoidCallback? onTap,
  VoidCallback? onDelete,
}) {
  return dsWrap(
    NotificationRowWidget(
      notification: notification,
      onTap: onTap ?? () {},
      onDelete: onDelete ?? () {},
    ),
    wrapInScaffold: true,
  );
}

// ────────────────────────────────────────────────────────────────────────────
// Tests
// ────────────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(disableDsFonts);

  group('NotificationRowWidget — rendering', () {
    testWidgets('renders title text', (WidgetTester tester) async {
      await tester.pumpWidget(_buildRow(notification: _kUnread));
      await tester.pump();
      expect(find.text(_kUnread.title), findsOneWidget);
    });

    testWidgets('renders body text when non-empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildRow(notification: _kUnread));
      await tester.pump();
      expect(find.text(_kUnread.body), findsOneWidget);
    });

    testWidgets('does not render body text when body is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildRow(notification: _kRead));
      await tester.pump();
      // Only the title text should be visible; no extra body text node.
      expect(find.text(_kRead.title), findsOneWidget);
    });

    testWidgets('unread indicator dot is visible for unread notifications', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildRow(notification: _kUnread));
      await tester.pump();
      // The unread dot is an AnimatedOpacity with opacity 1.
      final dots = tester.widgetList<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      final unreadDot = dots.firstWhere(
        (w) => w.opacity == 1.0,
        orElse: () => throw TestFailure(
          'Expected at least one AnimatedOpacity with opacity 1.0',
        ),
      );
      expect(unreadDot.opacity, 1.0);
    });

    testWidgets('unread indicator dot is invisible for read notifications', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildRow(notification: _kRead));
      await tester.pump();
      final dots = tester.widgetList<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      // All AnimatedOpacity widgets should have opacity 0 (dot hidden).
      for (final dot in dots) {
        expect(dot.opacity, 0.0);
      }
    });

    testWidgets('renders close icon for delete action', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildRow(notification: _kUnread));
      await tester.pump();
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('renders empty time label when createdAt is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildRow(notification: _kUnread));
      await tester.pump();
      // With no createdAt, _time returns '' — the Text widget still renders
      // but with an empty string (no relative time shown).
      expect(find.text(''), findsOneWidget);
    });

    testWidgets('shows "Xd ago" label when createdAt is days old', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildRow(notification: _kWithTime));
      await tester.pump();
      expect(find.textContaining('d ago'), findsOneWidget);
    });

    testWidgets('shows "Xh ago" label when createdAt is hours old', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildRow(notification: _kWithHours));
      await tester.pump();
      expect(find.textContaining('h ago'), findsOneWidget);
    });

    testWidgets('shows "Xm ago" label when createdAt is minutes old', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildRow(notification: _kWithMinutes));
      await tester.pump();
      expect(find.textContaining('m ago'), findsOneWidget);
    });

    testWidgets('shows "Just now" when createdAt is less than a minute ago', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildRow(notification: _kJustNow));
      await tester.pump();
      expect(find.text('Just now'), findsOneWidget);
    });
  });

  group('NotificationRowWidget — interactions', () {
    testWidgets('calls onTap when the row body is tapped', (
      WidgetTester tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        _buildRow(notification: _kUnread, onTap: () => tapped = true),
      );
      await tester.pump();

      await tester.tap(find.text(_kUnread.title));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('calls onDelete when the close icon is tapped', (
      WidgetTester tester,
    ) async {
      var deleted = false;
      await tester.pumpWidget(
        _buildRow(notification: _kUnread, onDelete: () => deleted = true),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(deleted, isTrue);
    });
  });
}
