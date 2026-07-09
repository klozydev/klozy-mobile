import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/profile_event.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/profile_tab.dart';

void main() {
  group('ProfileStarted', () {
    test('same userId are equal', () {
      expect(
        const ProfileStarted(userId: 'a'),
        const ProfileStarted(userId: 'a'),
      );
    });

    test('different userId are not equal', () {
      expect(
        const ProfileStarted(userId: 'a'),
        isNot(const ProfileStarted(userId: 'b')),
      );
    });
  });

  group('ProfileTabChanged', () {
    test('same tab are equal', () {
      expect(
        const ProfileTabChanged(ProfileTab.products),
        const ProfileTabChanged(ProfileTab.products),
      );
    });

    test('different tab are not equal', () {
      expect(
        const ProfileTabChanged(ProfileTab.products),
        isNot(const ProfileTabChanged(ProfileTab.reels)),
      );
    });
  });

  group('base ProfileEvent props', () {
    test('no-arg events with empty props are equal', () {
      expect(const ProfileFollowToggled(), const ProfileFollowToggled());
    });
  });
}
