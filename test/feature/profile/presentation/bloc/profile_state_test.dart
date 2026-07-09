import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/profile_state.dart';

void main() {
  group('ProfileLoadingState', () {
    test('two instances are equal', () {
      expect(const ProfileLoadingState(), const ProfileLoadingState());
    });
  });

  group('ProfileErrorState', () {
    test('same type are equal', () {
      expect(
        const ProfileErrorState(type: AppErrorType.network),
        const ProfileErrorState(type: AppErrorType.network),
      );
    });

    test('different type are not equal', () {
      expect(
        const ProfileErrorState(type: AppErrorType.network),
        isNot(const ProfileErrorState(type: AppErrorType.server)),
      );
    });
  });
}
