import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:klozy/src/feature/sell/presentation/bloc/sell_bloc.dart';
import 'package:klozy/src/feature/sell/presentation/bloc/sell_event.dart';
import 'package:klozy/src/feature/sell/presentation/bloc/sell_state.dart';
import 'package:klozy/src/feature/sell/presentation/widget/sell_photos_widget.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../../../support/ds_harness.dart';

// ---- Mocks ----------------------------------------------------------------

class _MockSellBloc extends Mock implements SellBloc {}

class _MockImagePickerPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements ImagePickerPlatform {}

// ---- Helpers --------------------------------------------------------------

bool _isImageError(FlutterErrorDetails d) {
  final msg = d.exception.toString();
  return msg.contains('FileSystemException') ||
      msg.contains('PathNotFoundException') ||
      msg.contains('NetworkImageLoadException') ||
      msg.contains('HTTP request failed');
}

_MockSellBloc _buildBloc() {
  final bloc = _MockSellBloc();
  when(() => bloc.state).thenReturn(const SellPhotosState(<String>[]));
  when(() => bloc.stream).thenAnswer((_) => const Stream<SellState>.empty());
  when(() => bloc.add(any())).thenReturn(null);
  when(() => bloc.close()).thenAnswer((_) async {});
  return bloc;
}

Widget _wrapWithBloc(_MockSellBloc bloc, SellPhotosState state) {
  return dsWrap(
    BlocProvider<SellBloc>.value(
      value: bloc,
      child: Scaffold(body: SellPhotosWidget(state: state)),
    ),
  );
}

void main() {
  late _MockSellBloc bloc;
  late _MockImagePickerPlatform mockPicker;
  void Function(FlutterErrorDetails)? originalError;

  setUpAll(() {
    disableDsFonts();
    registerFallbackValue(const SellAnalyzeRequested(<String>[]));
    registerFallbackValue(const SellStarted());
    registerFallbackValue(const MultiImagePickerOptions());
    registerFallbackValue(const ImagePickerOptions());
    registerFallbackValue(ImageSource.gallery);
  });

  setUp(() {
    bloc = _buildBloc();
    mockPicker = _MockImagePickerPlatform();
    ImagePickerPlatform.instance = mockPicker;

    // Default: return empty list for multi-image.
    when(
      () => mockPicker.getMultiImageWithOptions(options: any(named: 'options')),
    ).thenAnswer((_) async => <XFile>[]);

    // Default: return null for camera (cancel).
    when(
      () => mockPicker.getImageFromSource(
        source: any(named: 'source'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) async => null);

    originalError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails d) {
      if (_isImageError(d)) return;
      originalError?.call(d);
    };
  });

  tearDown(() {
    FlutterError.onError = originalError;
  });

  // ---- Empty state --------------------------------------------------------

  group('Empty state (no photos)', () {
    testWidgets('shows add-a-photo icon', (tester) async {
      await tester.pumpWidget(
        _wrapWithBloc(bloc, const SellPhotosState(<String>[])),
      );
      await tester.pump();

      expect(find.byIcon(Icons.add_a_photo), findsOneWidget);
    });

    testWidgets('shows camera hint text (at least one photo required)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithBloc(bloc, const SellPhotosState(<String>[])),
      );
      await tester.pump();

      expect(find.byIcon(Icons.camera_alt_outlined), findsAtLeastNWidgets(1));
    });

    testWidgets('continue button is disabled when no photos', (tester) async {
      await tester.pumpWidget(
        _wrapWithBloc(bloc, const SellPhotosState(<String>[])),
      );
      await tester.pump();

      // Tapping continue with empty list should NOT add SellAnalyzeRequested.
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      verifyNever(() => bloc.add(any<SellAnalyzeRequested>()));
    });
  });

  // ---- With photos --------------------------------------------------------

  group('With photos', () {
    const paths = [
      'https://cdn.klozy.com/a.jpg',
      'https://cdn.klozy.com/b.jpg',
    ];

    testWidgets('shows photo count indicator', (tester) async {
      await tester.pumpWidget(
        _wrapWithBloc(bloc, const SellPhotosState(paths)),
      );
      await tester.pump();

      expect(find.text('2/8'), findsOneWidget);
    });

    testWidgets(
      'continue button is enabled and dispatches SellAnalyzeRequested',
      (tester) async {
        await tester.pumpWidget(
          _wrapWithBloc(bloc, const SellPhotosState(paths)),
        );
        await tester.pump();

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        verify(() => bloc.add(any<SellAnalyzeRequested>())).called(1);
      },
    );

    testWidgets('remove button removes a photo from the grid', (tester) async {
      await tester.pumpWidget(
        _wrapWithBloc(bloc, const SellPhotosState(paths)),
      );
      await tester.pump();

      // Tap the close button on the first tile.
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pump();

      // Photo count decreased.
      expect(find.text('1/8'), findsOneWidget);
    });

    testWidgets('shows reorder hint text', (tester) async {
      await tester.pumpWidget(
        _wrapWithBloc(bloc, const SellPhotosState(paths)),
      );
      await tester.pump();

      // Reorder hint has an info_outline icon.
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    });

    testWidgets('shows cover badge on first tile', (tester) async {
      await tester.pumpWidget(
        _wrapWithBloc(bloc, const SellPhotosState(paths)),
      );
      await tester.pump();

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });
  });

  // ---- Max photos ---------------------------------------------------------

  group('Max photos (8)', () {
    final maxPaths = List.generate(8, (i) => 'https://cdn.klozy.com/$i.jpg');

    testWidgets('add tile not shown when at max capacity', (tester) async {
      await tester.pumpWidget(_wrapWithBloc(bloc, SellPhotosState(maxPaths)));
      await tester.pump();

      expect(find.byIcon(Icons.add_a_photo_outlined), findsNothing);
    });

    testWidgets('shows 8/8 count', (tester) async {
      await tester.pumpWidget(_wrapWithBloc(bloc, SellPhotosState(maxPaths)));
      await tester.pump();

      expect(find.text('8/8'), findsOneWidget);
    });
  });

  // ---- Gallery pick -------------------------------------------------------

  group('Gallery pick', () {
    testWidgets('appends picked photo from gallery', (tester) async {
      when(
        () =>
            mockPicker.getMultiImageWithOptions(options: any(named: 'options')),
      ).thenAnswer((_) async => <XFile>[XFile('/tmp/picked.jpg')]);

      await tester.pumpWidget(
        _wrapWithBloc(bloc, const SellPhotosState(<String>[])),
      );
      await tester.pump();

      // Tap the empty-state add button to open bottom sheet.
      await tester.tap(find.byIcon(Icons.add_a_photo));
      await tester.pumpAndSettle();

      // Tap Gallery option in the bottom sheet.
      await tester.tap(find.byIcon(Icons.image_outlined));
      await tester.pumpAndSettle();

      // One photo should now be in the grid.
      expect(find.text('1/8'), findsOneWidget);
    });

    testWidgets('cancel gallery pick (null result) does nothing', (
      tester,
    ) async {
      when(
        () =>
            mockPicker.getMultiImageWithOptions(options: any(named: 'options')),
      ).thenAnswer((_) async => <XFile>[]);

      await tester.pumpWidget(
        _wrapWithBloc(bloc, const SellPhotosState(<String>[])),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.add_a_photo));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.image_outlined));
      await tester.pumpAndSettle();

      // Still empty.
      expect(find.byIcon(Icons.add_a_photo), findsOneWidget);
    });
  });

  // ---- Camera pick --------------------------------------------------------

  group('Camera pick', () {
    testWidgets('appends photo taken with camera', (tester) async {
      when(
        () => mockPicker.getImageFromSource(
          source: any(named: 'source'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => XFile('/tmp/camera.jpg'));

      await tester.pumpWidget(
        _wrapWithBloc(bloc, const SellPhotosState(<String>[])),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.add_a_photo));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.camera_alt_outlined).last);
      await tester.pumpAndSettle();

      expect(find.text('1/8'), findsOneWidget);
    });

    testWidgets('cancel camera pick does nothing', (tester) async {
      when(
        () => mockPicker.getImageFromSource(
          source: any(named: 'source'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(
        _wrapWithBloc(bloc, const SellPhotosState(<String>[])),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.add_a_photo));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.camera_alt_outlined).last);
      await tester.pumpAndSettle();

      // Still empty.
      expect(find.byIcon(Icons.add_a_photo), findsOneWidget);
    });
  });

  // ---- Grid add tile -------------------------------------------------------

  group('Add tile in grid', () {
    testWidgets('tapping add tile in grid opens bottom sheet', (tester) async {
      await tester.pumpWidget(
        _wrapWithBloc(
          bloc,
          const SellPhotosState(['https://cdn.klozy.com/a.jpg']),
        ),
      );
      await tester.pump();

      // The add tile uses add_a_photo_outlined icon.
      await tester.tap(find.byIcon(Icons.add_a_photo_outlined));
      await tester.pumpAndSettle();

      // Bottom sheet should have camera/gallery options.
      expect(find.byIcon(Icons.camera_alt_outlined), findsAtLeastNWidgets(1));
    });
  });
}
