import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/app/notifications/notifications_cubit.dart';
import 'package:klozy/src/domain/notifications/entity/app_notification.dart';
import 'package:klozy/src/domain/notifications/entity/notification_type.dart';
import 'package:klozy/src/domain/notifications/notifications_repository.dart';
import 'package:klozy/src/feature/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:klozy/src/feature/notifications/presentation/bloc/notifications_event.dart';
import 'package:klozy/src/feature/notifications/presentation/bloc/notifications_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockNotificationsRepository extends Mock
    implements NotificationsRepository {}

class _MockNotificationsCubit extends Mock implements NotificationsCubit {}

Future<List<NotificationsState>> _collectStates(
  NotificationsBloc bloc,
  NotificationsEvent event,
) async {
  final states = <NotificationsState>[];
  final sub = bloc.stream.listen(states.add);
  bloc.add(event);
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return states;
}

const _kNotif = AppNotification(
  id: 'n1',
  type: NotificationType.newOrder,
  read: false,
);
const _kNotifRead = AppNotification(
  id: 'n1',
  type: NotificationType.newOrder,
  read: true,
);

void main() {
  late _MockNotificationsRepository mockRepo;
  late _MockNotificationsCubit mockCubit;
  late NotificationsBloc bloc;

  setUp(() {
    mockRepo = _MockNotificationsRepository();
    mockCubit = _MockNotificationsCubit();
    when(() => mockCubit.refresh()).thenAnswer((_) async {});
    when(() => mockCubit.clear()).thenReturn(null);
    bloc = NotificationsBloc(mockRepo, mockCubit);
  });

  tearDown(() => bloc.close());

  test('initial state is NotificationsLoadingState', () {
    expect(bloc.state, const NotificationsLoadingState());
  });

  group('NotificationsStarted', () {
    test('emits [loading, loaded] on success', () async {
      when(
        () => mockRepo.getNotifications(),
      ).thenAnswer((_) async => <AppNotification>[_kNotif]);

      final states = await _collectStates(bloc, const NotificationsStarted());

      expect(states, [
        const NotificationsLoadingState(),
        const NotificationsLoadedState(<AppNotification>[_kNotif]),
      ]);
    });

    test('emits [loading, error] on failure', () async {
      when(() => mockRepo.getNotifications()).thenThrow(Exception('network'));

      final states = await _collectStates(bloc, const NotificationsStarted());

      expect(states.first, const NotificationsLoadingState());
      expect(states.last, isA<NotificationsErrorState>());
    });
  });

  group('NotificationsReadAll', () {
    Future<void> loadItems() async {
      when(
        () => mockRepo.getNotifications(),
      ).thenAnswer((_) async => <AppNotification>[_kNotif]);
      final sub = bloc.stream.listen((_) {});
      bloc.add(const NotificationsStarted());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('marks all as read optimistically and calls repo', () async {
      await loadItems();
      when(() => mockRepo.markAllRead()).thenAnswer((_) async {});

      final states = await _collectStates(bloc, const NotificationsReadAll());

      final loaded = states.first as NotificationsLoadedState;
      expect(loaded.items.every((n) => n.read), isTrue);
      verify(() => mockRepo.markAllRead()).called(1);
      verify(() => mockCubit.clear()).called(1);
    });

    test('does nothing when already all read', () async {
      when(
        () => mockRepo.getNotifications(),
      ).thenAnswer((_) async => <AppNotification>[_kNotifRead]);
      final sub = bloc.stream.listen((_) {});
      bloc.add(const NotificationsStarted());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      final states = await _collectStates(bloc, const NotificationsReadAll());
      expect(states, isEmpty);
    });

    test('still calls clear even when markAllRead throws', () async {
      await loadItems();
      when(() => mockRepo.markAllRead()).thenThrow(Exception('server'));

      await _collectStates(bloc, const NotificationsReadAll());

      verify(() => mockCubit.clear()).called(1);
    });
  });

  group('NotificationMarkedRead', () {
    Future<void> loadItems() async {
      when(
        () => mockRepo.getNotifications(),
      ).thenAnswer((_) async => <AppNotification>[_kNotif]);
      final sub = bloc.stream.listen((_) {});
      bloc.add(const NotificationsStarted());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('flips target notification to read and calls repo', () async {
      await loadItems();
      when(() => mockRepo.markRead(any())).thenAnswer((_) async {});

      final states = await _collectStates(
        bloc,
        const NotificationMarkedRead('n1'),
      );

      final loaded = states.first as NotificationsLoadedState;
      expect(loaded.items.first.read, isTrue);
      verify(() => mockRepo.markRead('n1')).called(1);
    });
  });

  group('NotificationRemoved', () {
    Future<void> loadItems() async {
      when(
        () => mockRepo.getNotifications(),
      ).thenAnswer((_) async => <AppNotification>[_kNotif]);
      final sub = bloc.stream.listen((_) {});
      bloc.add(const NotificationsStarted());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('removes notification from list and calls repo', () async {
      await loadItems();
      when(() => mockRepo.remove(any())).thenAnswer((_) async {});

      final states = await _collectStates(
        bloc,
        const NotificationRemoved('n1'),
      );

      final loaded = states.first as NotificationsLoadedState;
      expect(loaded.items, isEmpty);
      verify(() => mockRepo.remove('n1')).called(1);
    });
  });
}
