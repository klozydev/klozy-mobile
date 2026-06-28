import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/app/notifications/notifications_cubit.dart';
import 'package:klozy/src/domain/notifications/notifications_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockNotificationsRepository extends Mock
    implements NotificationsRepository {}

void main() {
  late _MockNotificationsRepository mockRepo;
  late NotificationsCubit cubit;

  setUp(() {
    mockRepo = _MockNotificationsRepository();
    cubit = NotificationsCubit(mockRepo);
  });

  tearDown(() => cubit.close());

  test('initial state is 0', () {
    expect(cubit.state, 0);
  });

  group('load', () {
    test('emits unread count on success', () async {
      when(() => mockRepo.unreadCount()).thenAnswer((_) async => 5);

      await cubit.load();

      expect(cubit.state, 5);
    });

    test('keeps previous state on error', () async {
      when(() => mockRepo.unreadCount()).thenThrow(Exception('network'));

      await cubit.load();

      expect(cubit.state, 0);
    });
  });

  group('refresh', () {
    test('delegates to load', () async {
      when(() => mockRepo.unreadCount()).thenAnswer((_) async => 3);

      await cubit.refresh();

      expect(cubit.state, 3);
    });
  });

  group('clear', () {
    test('emits 0', () async {
      when(() => mockRepo.unreadCount()).thenAnswer((_) async => 7);
      await cubit.load();

      cubit.clear();

      expect(cubit.state, 0);
    });
  });
}
