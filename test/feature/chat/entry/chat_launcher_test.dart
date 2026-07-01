import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ChatLauncher extension is accessible on BuildContext', () {
    expect(
      BuildContext,
      isNotNull,
      reason: 'ChatLauncher extension targets BuildContext',
    );
  });
}
