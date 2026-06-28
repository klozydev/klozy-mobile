import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/app/cart/cart_cubit.dart';
import 'package:klozy/src/domain/cart/cart_repository.dart';
import 'package:klozy/src/domain/cart/entity/cart.dart';
import 'package:mocktail/mocktail.dart';

class _MockCartRepository extends Mock implements CartRepository {}

void main() {
  late _MockCartRepository mockRepo;
  late CartCubit cubit;

  setUp(() {
    mockRepo = _MockCartRepository();
    cubit = CartCubit(mockRepo);
  });

  tearDown(() => cubit.close());

  test('initial state is Cart.empty', () {
    expect(cubit.state, Cart.empty);
    expect(cubit.itemCount, 0);
  });

  group('load', () {
    test('emits fetched cart on success', () async {
      const cart = Cart.empty;
      when(() => mockRepo.getCart()).thenAnswer((_) async => cart);

      await cubit.load();

      expect(cubit.state, cart);
    });

    test('keeps previous state on error', () async {
      when(() => mockRepo.getCart()).thenThrow(Exception('network'));

      await cubit.load();

      expect(cubit.state, Cart.empty);
    });
  });

  group('refresh', () {
    test('delegates to load', () async {
      const cart = Cart.empty;
      when(() => mockRepo.getCart()).thenAnswer((_) async => cart);

      await cubit.refresh();

      expect(cubit.state, cart);
    });
  });

  group('add', () {
    test('calls addItem then reloads on success', () async {
      const cart = Cart.empty;
      when(() => mockRepo.addItem(any())).thenAnswer((_) async {});
      when(() => mockRepo.getCart()).thenAnswer((_) async => cart);

      await cubit.add('p1');

      verify(() => mockRepo.addItem('p1')).called(1);
      expect(cubit.state, cart);
    });

    test('rethrows when addItem fails', () {
      when(() => mockRepo.addItem(any())).thenThrow(Exception('server'));

      expect(() => cubit.add('p1'), throwsException);
    });
  });

  group('remove', () {
    test('calls removeItem then reloads on success', () async {
      const cart = Cart.empty;
      when(() => mockRepo.removeItem(any())).thenAnswer((_) async {});
      when(() => mockRepo.getCart()).thenAnswer((_) async => cart);

      await cubit.remove('p1');

      verify(() => mockRepo.removeItem('p1')).called(1);
    });

    test('silently ignores error from removeItem and still reloads', () async {
      const cart = Cart.empty;
      when(() => mockRepo.removeItem(any())).thenThrow(Exception('server'));
      when(() => mockRepo.getCart()).thenAnswer((_) async => cart);

      await cubit.remove('p1');

      expect(cubit.state, cart);
    });
  });
}
