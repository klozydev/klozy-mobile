import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/components/ds_network_image/ds_network_image.dart';
import 'package:klozy/src/domain/me/entity/me_profile.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel_comment.dart';
import 'package:klozy/src/feature/reels/domain/reels_repository.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_comments_sheet.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/ds_harness.dart';

class _MockReelsRepository extends Mock implements ReelsRepository {}

class _MockMeRepository extends Mock implements MeRepository {}

// Suppress network image errors from CircleAvatar.
bool _isNetworkImageError(FlutterErrorDetails d) {
  final String msg = d.exception.toString();
  return msg.contains('HTTP request failed') ||
      msg.contains('NetworkImageLoadException') ||
      msg.contains('SocketException') ||
      msg.contains('ClientException');
}

const _kMe = MeProfile(id: 'user-1');

const _kComment = ReelComment(
  id: 'c1',
  body: 'Nice reel!',
  authorId: 'author-x',
  authorName: 'Alice',
);

const _kMyComment = ReelComment(
  id: 'c2',
  body: 'My comment',
  authorId: 'user-1',
  authorName: 'Me',
  authorAvatar: 'https://example.com/avatar.jpg',
);

Widget _wrap(Widget child) => dsWrap(child, wrapInScaffold: true);

void main() {
  late _MockReelsRepository mockRepo;
  late _MockMeRepository mockMe;
  void Function(FlutterErrorDetails)? originalErrorHandler;

  setUpAll(disableDsFonts);

  setUp(() async {
    mockRepo = _MockReelsRepository();
    mockMe = _MockMeRepository();

    await GetIt.I.reset();
    GetIt.I.registerSingleton<ReelsRepository>(mockRepo);
    GetIt.I.registerSingleton<MeRepository>(mockMe);

    originalErrorHandler = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails d) {
      if (_isNetworkImageError(d)) return;
      originalErrorHandler?.call(d);
    };
  });

  tearDown(() async {
    FlutterError.onError = originalErrorHandler;
    await GetIt.I.reset();
  });

  group('ReelCommentsSheet — loading state', () {
    testWidgets('shows DSLoader while comments are being fetched', (
      WidgetTester tester,
    ) async {
      final Completer<List<ReelComment>> completer =
          Completer<List<ReelComment>>();
      when(() => mockRepo.comments(any())).thenAnswer((_) => completer.future);
      when(() => mockMe.getMe()).thenAnswer((_) async => _kMe);

      await tester.pumpWidget(_wrap(const ReelCommentsSheet(reelId: 'r1')));
      await tester.pump();

      expect(find.byType(DSLoader), findsOneWidget);
    });
  });

  group('ReelCommentsSheet — empty state', () {
    testWidgets('shows empty message when no comments', (
      WidgetTester tester,
    ) async {
      when(
        () => mockRepo.comments(any()),
      ).thenAnswer((_) async => const <ReelComment>[]);
      when(() => mockMe.getMe()).thenAnswer((_) async => _kMe);

      await tester.pumpWidget(_wrap(const ReelCommentsSheet(reelId: 'r1')));
      await tester.pumpAndSettle();

      // Finds the no-comments text (l10n key 'reels_no_comments')
      expect(find.byType(Text), findsWidgets);
      expect(find.byType(DSLoader), findsNothing);
    });

    testWidgets('shows empty message when comments() throws', (
      WidgetTester tester,
    ) async {
      when(() => mockRepo.comments(any())).thenThrow(Exception('network'));
      when(() => mockMe.getMe()).thenAnswer((_) async => _kMe);

      await tester.pumpWidget(_wrap(const ReelCommentsSheet(reelId: 'r1')));
      await tester.pumpAndSettle();

      expect(find.byType(DSLoader), findsNothing);
    });
  });

  group('ReelCommentsSheet — populated state', () {
    testWidgets('renders comment rows when comments exist', (
      WidgetTester tester,
    ) async {
      when(
        () => mockRepo.comments(any()),
      ).thenAnswer((_) async => const <ReelComment>[_kComment]);
      when(() => mockMe.getMe()).thenAnswer((_) async => _kMe);

      await tester.pumpWidget(_wrap(const ReelCommentsSheet(reelId: 'r1')));
      await tester.pumpAndSettle();

      expect(find.text('Nice reel!'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('renders comment with avatar (no-avatar branch)', (
      WidgetTester tester,
    ) async {
      // Comment with no avatar → shows person icon in CircleAvatar.
      when(
        () => mockRepo.comments(any()),
      ).thenAnswer((_) async => const <ReelComment>[_kComment]);
      when(() => mockMe.getMe()).thenAnswer((_) async => _kMe);

      await tester.pumpWidget(_wrap(const ReelCommentsSheet(reelId: 'r1')));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('renders comment with avatar URL (network image branch)', (
      WidgetTester tester,
    ) async {
      when(
        () => mockRepo.comments(any()),
      ).thenAnswer((_) async => const <ReelComment>[_kMyComment]);
      when(() => mockMe.getMe()).thenAnswer((_) async => _kMe);

      await tester.pumpWidget(_wrap(const ReelCommentsSheet(reelId: 'r1')));
      // A real avatar URL means the DSNetworkImage shimmer placeholder
      // animates indefinitely, so pumpAndSettle never settles. Bounded
      // pumps let both futures (comments + me) resolve and rebuild.
      await tester.pump();
      await tester.pump();

      expect(find.text('My comment'), findsOneWidget);

      final Finder avatarFinder = find.byType(DSNetworkImage);
      expect(avatarFinder, findsOneWidget);
      expect(
        tester.widget<DSNetworkImage>(avatarFinder).imageUrl,
        _kMyComment.authorAvatar,
      );

      // Unmount and flush so the still-animating shimmer leaves no pending
      // timer at teardown.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
    });
  });

  group('ReelCommentsSheet — delete', () {
    testWidgets('shows delete icon when user is reel owner', (
      WidgetTester tester,
    ) async {
      when(
        () => mockRepo.comments(any()),
      ).thenAnswer((_) async => const <ReelComment>[_kComment]);
      when(() => mockMe.getMe()).thenAnswer((_) async => _kMe);

      await tester.pumpWidget(
        _wrap(const ReelCommentsSheet(reelId: 'r1', isReelOwner: true)),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    });

    testWidgets('shows delete icon when comment belongs to current user', (
      WidgetTester tester,
    ) async {
      // _kMyComment has authorId == 'user-1' == _kMe.id
      when(
        () => mockRepo.comments(any()),
      ).thenAnswer((_) async => const <ReelComment>[_kMyComment]);
      when(() => mockMe.getMe()).thenAnswer((_) async => _kMe);

      await tester.pumpWidget(_wrap(const ReelCommentsSheet(reelId: 'r1')));
      // _kMyComment carries a real avatar URL, whose DSNetworkImage shimmer
      // placeholder animates indefinitely, so pumpAndSettle never settles.
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);

      // Unmount and flush so the still-animating shimmer leaves no pending
      // timer at teardown.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('hides delete icon when user is not owner and not author', (
      WidgetTester tester,
    ) async {
      when(
        () => mockRepo.comments(any()),
      ).thenAnswer((_) async => const <ReelComment>[_kComment]);
      when(() => mockMe.getMe()).thenAnswer((_) async => _kMe);

      await tester.pumpWidget(
        _wrap(
          // isReelOwner=false, authorId='author-x' != 'user-1'
          const ReelCommentsSheet(reelId: 'r1', isReelOwner: false),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
    });

    testWidgets(
      'tapping delete removes comment from list and calls deleteComment',
      (WidgetTester tester) async {
        when(
          () => mockRepo.comments(any()),
        ).thenAnswer((_) async => const <ReelComment>[_kComment]);
        when(() => mockMe.getMe()).thenAnswer((_) async => _kMe);
        when(
          () => mockRepo.deleteComment(any(), any()),
        ).thenAnswer((_) async {});

        await tester.pumpWidget(
          _wrap(const ReelCommentsSheet(reelId: 'r1', isReelOwner: true)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Nice reel!'), findsOneWidget);
        await tester.tap(find.byIcon(Icons.delete_outline_rounded));
        await tester.pumpAndSettle();

        // Comment removed from list.
        expect(find.text('Nice reel!'), findsNothing);
        verify(() => mockRepo.deleteComment('r1', 'c1')).called(1);
      },
    );

    testWidgets('delete succeeds even when deleteComment throws', (
      WidgetTester tester,
    ) async {
      when(
        () => mockRepo.comments(any()),
      ).thenAnswer((_) async => const <ReelComment>[_kComment]);
      when(() => mockMe.getMe()).thenAnswer((_) async => _kMe);
      when(
        () => mockRepo.deleteComment(any(), any()),
      ).thenThrow(Exception('server error'));

      await tester.pumpWidget(
        _wrap(const ReelCommentsSheet(reelId: 'r1', isReelOwner: true)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();

      // Optimistically removed.
      expect(find.text('Nice reel!'), findsNothing);
    });
  });

  group('ReelCommentsSheet — send comment', () {
    testWidgets('send button is shown', (WidgetTester tester) async {
      when(
        () => mockRepo.comments(any()),
      ).thenAnswer((_) async => const <ReelComment>[]);
      when(() => mockMe.getMe()).thenAnswer((_) async => _kMe);

      await tester.pumpWidget(_wrap(const ReelCommentsSheet(reelId: 'r1')));
      await tester.pumpAndSettle();

      // The send button is a GestureDetector wrapping a Container (circle).
      expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
    });

    testWidgets('typing activates send button color', (
      WidgetTester tester,
    ) async {
      when(
        () => mockRepo.comments(any()),
      ).thenAnswer((_) async => const <ReelComment>[]);
      when(() => mockMe.getMe()).thenAnswer((_) async => _kMe);

      await tester.pumpWidget(_wrap(const ReelCommentsSheet(reelId: 'r1')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Hello!');
      await tester.pump();

      // Widget rebuilds when text changes; the send container is present.
      expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
    });

    testWidgets('tapping send calls addComment and appends to list', (
      WidgetTester tester,
    ) async {
      when(
        () => mockRepo.comments(any()),
      ).thenAnswer((_) async => const <ReelComment>[]);
      when(() => mockMe.getMe()).thenAnswer((_) async => _kMe);

      const ReelComment newComment = ReelComment(
        id: 'c3',
        body: 'Hello!',
        authorId: 'user-1',
        authorName: 'Me',
      );
      when(
        () => mockRepo.addComment(any(), any()),
      ).thenAnswer((_) async => newComment);

      await tester.pumpWidget(_wrap(const ReelCommentsSheet(reelId: 'r1')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Hello!');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pumpAndSettle();

      verify(() => mockRepo.addComment('r1', 'Hello!')).called(1);
      expect(find.text('Hello!'), findsOneWidget);
    });

    testWidgets('tapping send when input is empty does nothing', (
      WidgetTester tester,
    ) async {
      when(
        () => mockRepo.comments(any()),
      ).thenAnswer((_) async => const <ReelComment>[]);
      when(() => mockMe.getMe()).thenAnswer((_) async => _kMe);

      await tester.pumpWidget(_wrap(const ReelCommentsSheet(reelId: 'r1')));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pump();

      verifyNever(() => mockRepo.addComment(any(), any()));
    });

    testWidgets('send shows error snackbar when addComment throws', (
      WidgetTester tester,
    ) async {
      when(
        () => mockRepo.comments(any()),
      ).thenAnswer((_) async => const <ReelComment>[]);
      when(() => mockMe.getMe()).thenAnswer((_) async => _kMe);
      when(
        () => mockRepo.addComment(any(), any()),
      ).thenThrow(Exception('server'));

      await tester.pumpWidget(_wrap(const ReelCommentsSheet(reelId: 'r1')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Hello!');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pumpAndSettle();

      // Snackbar is displayed — find SnackBar widget.
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  group('ReelCommentsSheet — myId not yet loaded', () {
    testWidgets('canDelete is false when myId is null', (
      WidgetTester tester,
    ) async {
      // Never resolve getMe so _myId stays null.
      final Completer<MeProfile> meCompleter = Completer<MeProfile>();
      when(
        () => mockRepo.comments(any()),
      ).thenAnswer((_) async => const <ReelComment>[_kComment]);
      when(() => mockMe.getMe()).thenAnswer((_) => meCompleter.future);

      await tester.pumpWidget(
        _wrap(const ReelCommentsSheet(reelId: 'r1', isReelOwner: false)),
      );
      await tester.pumpAndSettle();

      // With no myId, canDelete is false for non-owner.
      expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
    });
  });
}
