import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/data/mapper/chat_time_formatter.dart';

void main() {
  group('ChatTimeFormatter.label', () {
    test('null time returns empty string', () {
      expect(ChatTimeFormatter.label(null), isEmpty);
    });

    test('null time with explicit now returns empty string', () {
      expect(
        ChatTimeFormatter.label(null, now: DateTime(2024, 1, 1, 12)),
        isEmpty,
      );
    });

    // Negative diff (future) — not explicitly covered by the spec but the code
    // falls through to DateFormat so it won't crash.
    test('does not crash for future time', () {
      final now = DateTime(2024, 6, 15, 10, 0, 0);
      final future = DateTime(2024, 6, 15, 10, 0, 30);
      // diff.inSeconds < 0, so the `now` branch is NOT triggered.
      // The code proceeds to day-diff logic (same day → HH:mm).
      final label = ChatTimeFormatter.label(future, now: now);
      expect(label, isNotEmpty);
    });

    group('< 60 seconds → "now"', () {
      test('0 seconds ago', () {
        final t = DateTime(2024, 6, 15, 10, 0, 0);
        expect(ChatTimeFormatter.label(t, now: t), 'now');
      });

      test('30 seconds ago', () {
        final now = DateTime(2024, 6, 15, 10, 0, 30);
        final t = DateTime(2024, 6, 15, 10, 0, 0);
        expect(ChatTimeFormatter.label(t, now: now), 'now');
      });

      test('59 seconds ago', () {
        final now = DateTime(2024, 6, 15, 10, 0, 59);
        final t = DateTime(2024, 6, 15, 10, 0, 0);
        expect(ChatTimeFormatter.label(t, now: now), 'now');
      });
    });

    group('same day (dayDiff == 0) → HH:mm', () {
      test('2 minutes ago → HH:mm', () {
        final t = DateTime(2024, 6, 15, 14, 5, 0);
        final now = DateTime(2024, 6, 15, 14, 7, 30);
        final label = ChatTimeFormatter.label(t, now: now);
        // Should be HH:mm of t = 14:05
        expect(label, '14:05');
      });

      test('1 hour ago same day → HH:mm', () {
        final t = DateTime(2024, 6, 15, 9, 30, 0);
        final now = DateTime(2024, 6, 15, 10, 35, 0);
        final label = ChatTimeFormatter.label(t, now: now);
        expect(label, '09:30');
      });

      test('dayDiff == 0 even near midnight', () {
        final t = DateTime(2024, 6, 15, 0, 1, 0);
        final now = DateTime(2024, 6, 15, 23, 59, 0);
        final label = ChatTimeFormatter.label(t, now: now);
        expect(label, '00:01');
      });
    });

    group('yesterday (dayDiff == 1) → "Yesterday"', () {
      test('exactly yesterday', () {
        final t = DateTime(2024, 6, 14, 20, 0, 0);
        final now = DateTime(2024, 6, 15, 10, 0, 0);
        expect(ChatTimeFormatter.label(t, now: now), 'Yesterday');
      });

      test('yesterday just before midnight', () {
        final t = DateTime(2024, 6, 14, 23, 59, 0);
        final now = DateTime(2024, 6, 15, 0, 1, 0);
        expect(ChatTimeFormatter.label(t, now: now), 'Yesterday');
      });
    });

    group('this week (1 < dayDiff < 7) → weekday abbreviation', () {
      test('2 days ago → weekday name', () {
        // 2024-06-13 is a Thursday
        final t = DateTime(2024, 6, 13, 10, 0, 0);
        final now = DateTime(2024, 6, 15, 10, 0, 0); // Saturday
        final label = ChatTimeFormatter.label(t, now: now);
        // DateFormat.E() locale-dependent; at minimum it should not be a
        // raw date, "Yesterday", or "now".
        expect(label, isNot('now'));
        expect(label, isNot('Yesterday'));
        expect(label, isNot(matches(r'^\d{2}/\d{2}/\d{2}$')));
      });

      test('6 days ago → weekday', () {
        final t = DateTime(2024, 6, 9, 10, 0, 0);
        final now = DateTime(2024, 6, 15, 10, 0, 0);
        final label = ChatTimeFormatter.label(t, now: now);
        expect(label, isNot(matches(r'^\d{2}/\d{2}/\d{2}$')));
        expect(label, isNot('Yesterday'));
      });
    });

    group('>= 7 days ago → dd/MM/yy', () {
      test('exactly 7 days ago → dd/MM/yy', () {
        final t = DateTime(2024, 6, 8, 10, 0, 0);
        final now = DateTime(2024, 6, 15, 10, 0, 0);
        final label = ChatTimeFormatter.label(t, now: now);
        expect(label, '08/06/24');
      });

      test('30 days ago → dd/MM/yy', () {
        final t = DateTime(2024, 5, 16, 12, 0, 0);
        final now = DateTime(2024, 6, 15, 12, 0, 0);
        final label = ChatTimeFormatter.label(t, now: now);
        expect(label, '16/05/24');
      });

      test('last year → dd/MM/yy', () {
        final t = DateTime(2023, 12, 31, 12, 0, 0);
        final now = DateTime(2024, 6, 15, 12, 0, 0);
        final label = ChatTimeFormatter.label(t, now: now);
        expect(label, '31/12/23');
      });
    });
  });
}
