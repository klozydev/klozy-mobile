import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/core/util/instagram_link.dart';

void main() {
  group('instagramUrl', () {
    test('resolves a bare handle to an instagram.com URL', () {
      expect(instagramUrl('klozy_uae'), 'https://instagram.com/klozy_uae');
    });

    test('strips a leading @ from the handle', () {
      expect(instagramUrl('@klozy_uae'), 'https://instagram.com/klozy_uae');
    });

    test('trims surrounding whitespace before resolving', () {
      expect(instagramUrl('  @klozy_uae  '), 'https://instagram.com/klozy_uae');
    });

    test('passes through an https URL unchanged', () {
      expect(
        instagramUrl('https://www.instagram.com/klozy_uae/'),
        'https://www.instagram.com/klozy_uae/',
      );
    });

    test('passes through an http URL unchanged', () {
      expect(
        instagramUrl('http://instagram.com/klozy_uae'),
        'http://instagram.com/klozy_uae',
      );
    });
  });

  group('instagramHandleDisplay', () {
    test('prefixes a bare handle with @', () {
      expect(instagramHandleDisplay('klozy_uae'), '@klozy_uae');
    });

    test('keeps an existing @ prefix', () {
      expect(instagramHandleDisplay('@klozy_uae'), '@klozy_uae');
    });

    test('trims surrounding whitespace', () {
      expect(instagramHandleDisplay('  klozy_uae '), '@klozy_uae');
    });

    test('extracts the handle from a full URL', () {
      expect(
        instagramHandleDisplay('https://www.instagram.com/klozy_uae/'),
        '@klozy_uae',
      );
    });

    test('falls back to the raw URL when the path has no segments', () {
      expect(
        instagramHandleDisplay('https://instagram.com'),
        '@https://instagram.com',
      );
    });
  });
}
