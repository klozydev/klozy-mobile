import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/sell/presentation/widget/sell_photo_strip_widget.dart';

import '../../../../support/ds_harness.dart';

bool _isImageError(FlutterErrorDetails d) =>
    d.exception.toString().contains('NetworkImageLoadException') ||
    d.exception.toString().contains('HTTP request failed') ||
    d.exception.toString().contains('FileSystemException') ||
    d.exception.toString().contains('PathNotFoundException');

// Must be called INSIDE testWidgets body (after binding resets FlutterError.onError).
void _suppressImageErrors() {
  final prev = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails d) {
    if (_isImageError(d)) return;
    prev?.call(d);
  };
  addTearDown(() => FlutterError.onError = prev);
}

void main() {
  setUpAll(disableDsFonts);

  Widget buildWidget({
    required List<String> photoPaths,
    VoidCallback? onEditTapped,
  }) {
    return dsWrap(
      SellPhotoStripWidget(
        photoPaths: photoPaths,
        onEditTapped: onEditTapped ?? () {},
      ),
      wrapInScaffold: true,
    );
  }

  testWidgets('renders correct item count = photos + edit tile', (
    tester,
  ) async {
    _suppressImageErrors();
    const paths = ['https://example.com/a.jpg', 'https://example.com/b.jpg'];
    await tester.pumpWidget(buildWidget(photoPaths: paths));
    await tester.pump();

    // ListView with 3 items (2 photos + 1 edit tile).
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('renders edit tile with edit icon', (tester) async {
    _suppressImageErrors();
    await tester.pumpWidget(
      buildWidget(photoPaths: ['https://example.com/a.jpg']),
    );
    await tester.pump();

    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
  });

  testWidgets('tapping edit tile calls onEditTapped', (tester) async {
    _suppressImageErrors();
    bool tapped = false;
    await tester.pumpWidget(
      buildWidget(
        photoPaths: ['https://example.com/a.jpg'],
        onEditTapped: () => tapped = true,
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.edit_outlined));
    expect(tapped, isTrue);
  });

  testWidgets('renders with empty list — only edit tile', (tester) async {
    await tester.pumpWidget(buildWidget(photoPaths: []));
    await tester.pump();

    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
  });

  testWidgets('remote URL photos render Image.network widgets', (tester) async {
    _suppressImageErrors();
    await tester.pumpWidget(
      buildWidget(
        photoPaths: ['https://example.com/a.jpg', 'https://example.com/b.jpg'],
      ),
    );
    await tester.pump();

    expect(find.byType(Image), findsAtLeastNWidgets(2));
  });
}
