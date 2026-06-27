import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/chat/data/converter/timestamp_converter.dart';

void main() {
  const TimestampConverter converter = TimestampConverter();

  // ── fromJson ────────────────────────────────────────────────────────────────

  group('TimestampConverter.fromJson', () {
    test('returns null for null input', () {
      expect(converter.fromJson(null), isNull);
    });

    test('converts Firestore Timestamp to DateTime', () {
      final DateTime dt = DateTime.utc(2024, 6, 15, 12, 30, 0);
      final Timestamp ts = Timestamp.fromDate(dt);

      final DateTime? result = converter.fromJson(ts);

      // Timestamp.toDate() may return local or UTC DateTime depending on SDK
      // version — compare via isAtSameMomentAs to be timezone-agnostic.
      expect(result, isNotNull);
      expect(result!.isAtSameMomentAs(dt), isTrue);
    });

    test('converts int millis to DateTime', () {
      final DateTime expected = DateTime.fromMillisecondsSinceEpoch(
        1_718_448_000_000,
      );

      final DateTime? result = converter.fromJson(1_718_448_000_000);

      expect(result, expected);
    });

    test('returns DateTime directly when passed a DateTime', () {
      final DateTime dt = DateTime(2024, 1, 1, 0, 0, 0);

      final DateTime? result = converter.fromJson(dt);

      expect(result, dt);
    });

    test('returns null for unknown type', () {
      final DateTime? result = converter.fromJson('2024-06-15T12:00:00Z');

      expect(result, isNull);
    });

    test('converts epoch int 0 to UTC epoch start', () {
      final DateTime expected = DateTime.fromMillisecondsSinceEpoch(0);

      final DateTime? result = converter.fromJson(0);

      expect(result, expected);
    });
  });

  // ── toJson ──────────────────────────────────────────────────────────────────

  group('TimestampConverter.toJson', () {
    test('returns null for null input', () {
      expect(converter.toJson(null), isNull);
    });

    test('converts DateTime to Firestore Timestamp', () {
      final DateTime dt = DateTime.utc(2024, 6, 15, 12, 30, 0);

      final Object? result = converter.toJson(dt);

      expect(result, isA<Timestamp>());
      expect((result as Timestamp).toDate().isAtSameMomentAs(dt), isTrue);
    });

    test(
      'round-trip: Timestamp → fromJson → toJson → Timestamp is identity',
      () {
        final DateTime dt = DateTime.utc(2024, 3, 20, 8, 0, 0);
        final Timestamp original = Timestamp.fromDate(dt);

        final DateTime? mid = converter.fromJson(original);
        final Object? back = converter.toJson(mid);

        expect(back, isA<Timestamp>());
        expect((back as Timestamp).seconds, original.seconds);
        expect(back.nanoseconds, original.nanoseconds);
      },
    );

    test('round-trip: int millis → fromJson → toJson keeps same moment', () {
      const int millis = 1_718_448_000_000;
      final DateTime mid = converter.fromJson(millis)!;
      final Object? back = converter.toJson(mid);

      expect(back, isA<Timestamp>());
      expect((back as Timestamp).millisecondsSinceEpoch, millis);
    });
  });
}
