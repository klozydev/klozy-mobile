import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/me/entity/notification_settings.dart';

void main() {
  group('NotificationSettings', () {
    test('defaults push and email to true', () {
      const NotificationSettings settings = NotificationSettings();
      expect(settings.push, isTrue);
      expect(settings.email, isTrue);
    });

    test('constructor sets push and email', () {
      const NotificationSettings settings = NotificationSettings(
        push: false,
        email: false,
      );
      expect(settings.push, isFalse);
      expect(settings.email, isFalse);
    });

    test('two instances with same fields are equal', () {
      const NotificationSettings a = NotificationSettings();
      const NotificationSettings b = NotificationSettings(
        push: true,
        email: true,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('instances with different push are not equal', () {
      const NotificationSettings a = NotificationSettings(push: true);
      const NotificationSettings b = NotificationSettings(push: false);
      expect(a, isNot(equals(b)));
    });

    test('copyWith changes push', () {
      const NotificationSettings original = NotificationSettings();
      final NotificationSettings updated = original.copyWith(push: false);
      expect(updated.push, isFalse);
      expect(updated.email, isTrue);
    });

    test('copyWith changes email', () {
      const NotificationSettings original = NotificationSettings();
      final NotificationSettings updated = original.copyWith(email: false);
      expect(updated.email, isFalse);
      expect(updated.push, isTrue);
    });

    test('copyWith with no args preserves all fields', () {
      const NotificationSettings original = NotificationSettings(
        push: false,
        email: true,
      );
      final NotificationSettings updated = original.copyWith();
      expect(updated, equals(original));
    });
  });
}
