import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/feature/reels/domain/reels_repository.dart';
import 'package:klozy/src/feature/reels/presentation/bloc/reel_composer_bloc.dart';
import 'package:klozy/src/feature/reels/presentation/bloc/reel_composer_event.dart';
import 'package:klozy/src/feature/reels/presentation/bloc/reel_composer_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockReelsRepository extends Mock implements ReelsRepository {}

Future<List<ReelComposerState>> _collectStates(
  ReelComposerBloc bloc,
  ReelComposerEvent event,
) async {
  final states = <ReelComposerState>[];
  final sub = bloc.stream.listen(states.add);
  bloc.add(event);
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return states;
}

const _kProduct = Product(id: 'p1', title: 'Shirt', price: 50);

void main() {
  late _MockReelsRepository mockRepo;
  late ReelComposerBloc bloc;

  setUp(() {
    mockRepo = _MockReelsRepository();
    bloc = ReelComposerBloc(mockRepo);
  });

  tearDown(() => bloc.close());

  test('initial state is ReelComposerLoading', () {
    expect(bloc.state, const ReelComposerLoading());
  });

  group('ReelComposerStarted', () {
    test('emits [loading, ready(products)] on success', () async {
      when(
        () => mockRepo.myProducts(),
      ).thenAnswer((_) async => const <Product>[_kProduct]);

      final states = await _collectStates(bloc, const ReelComposerStarted());

      expect(states.first, const ReelComposerLoading());
      final ready = states.last as ReelComposerReady;
      expect(ready.products, [_kProduct]);
    });

    test('emits [loading, ready(empty)] when myProducts throws', () async {
      when(() => mockRepo.myProducts()).thenThrow(Exception('network'));

      final states = await _collectStates(bloc, const ReelComposerStarted());

      expect(states.first, const ReelComposerLoading());
      final ready = states.last as ReelComposerReady;
      expect(ready.products, isEmpty);
    });
  });

  group('ReelComposerSubmitted', () {
    Future<void> startBloc() async {
      when(
        () => mockRepo.myProducts(),
      ).thenAnswer((_) async => const <Product>[_kProduct]);
      final sub = bloc.stream.listen((_) {});
      bloc.add(const ReelComposerStarted());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('emits [posting, done] on success', () async {
      await startBloc();
      when(
        () => mockRepo.createReel(
          caption: any(named: 'caption'),
          taggedProductIds: any(named: 'taggedProductIds'),
        ),
      ).thenAnswer(
        (_) async => (reelId: 'r1', uploadUrl: 'https://upload.example.com/r1'),
      );
      when(() => mockRepo.uploadVideo(any(), any())).thenAnswer((_) async {});

      final states = await _collectStates(
        bloc,
        const ReelComposerSubmitted(videoPath: '/tmp/video.mp4'),
      );

      expect(states.first, const ReelComposerPosting());
      expect(states.last, const ReelComposerDone());
    });

    test(
      'emits [posting, ready(errorMessage)] when uploadUrl is empty',
      () async {
        await startBloc();
        when(
          () => mockRepo.createReel(
            caption: any(named: 'caption'),
            taggedProductIds: any(named: 'taggedProductIds'),
          ),
        ).thenAnswer((_) async => (reelId: 'r1', uploadUrl: ''));

        final states = await _collectStates(
          bloc,
          const ReelComposerSubmitted(videoPath: '/tmp/video.mp4'),
        );

        expect(states.first, const ReelComposerPosting());
        final ready = states.last as ReelComposerReady;
        expect(ready.errorReason, isNotNull);
      },
    );

    test(
      'emits [posting, ready(errorMessage)] when createReel throws',
      () async {
        await startBloc();
        when(
          () => mockRepo.createReel(
            caption: any(named: 'caption'),
            taggedProductIds: any(named: 'taggedProductIds'),
          ),
        ).thenThrow(Exception('server'));

        final states = await _collectStates(
          bloc,
          const ReelComposerSubmitted(videoPath: '/tmp/video.mp4'),
        );

        expect(states.first, const ReelComposerPosting());
        final ready = states.last as ReelComposerReady;
        expect(ready.errorReason, isNotNull);
        // Products are preserved from the previous ready state
        expect(ready.products, [_kProduct]);
      },
    );

    test(
      'emits [posting, ready(errorMessage)] when uploadVideo throws',
      () async {
        await startBloc();
        when(
          () => mockRepo.createReel(
            caption: any(named: 'caption'),
            taggedProductIds: any(named: 'taggedProductIds'),
          ),
        ).thenAnswer(
          (_) async =>
              (reelId: 'r1', uploadUrl: 'https://upload.example.com/r1'),
        );
        when(
          () => mockRepo.uploadVideo(any(), any()),
        ).thenThrow(Exception('upload failed'));

        final states = await _collectStates(
          bloc,
          const ReelComposerSubmitted(videoPath: '/tmp/video.mp4'),
        );

        final ready = states.last as ReelComposerReady;
        expect(ready.errorReason, isNotNull);
      },
    );
  });
}
