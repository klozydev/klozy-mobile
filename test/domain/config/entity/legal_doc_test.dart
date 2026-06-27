import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/config/entity/legal_doc.dart';

void main() {
  group('LegalDoc', () {
    const LegalDoc doc = LegalDoc(
      key: 'privacy',
      name: 'Privacy Policy',
      version: '2.0',
    );

    test('getters return constructor values', () {
      expect(doc.key, 'privacy');
      expect(doc.name, 'Privacy Policy');
      expect(doc.version, '2.0');
    });

    test('optional fields default to empty / null', () {
      const LegalDoc minimal = LegalDoc(key: 'terms');
      expect(minimal.name, '');
      expect(minimal.version, isNull);
    });

    test('two instances with same fields are equal', () {
      const LegalDoc other = LegalDoc(
        key: 'privacy',
        name: 'Privacy Policy',
        version: '2.0',
      );
      expect(doc, equals(other));
      expect(doc.hashCode, equals(other.hashCode));
    });

    test('instances with different key are not equal', () {
      const LegalDoc other = LegalDoc(key: 'terms');
      expect(doc, isNot(equals(other)));
    });
  });

  group('LegalDocContent', () {
    const LegalDocContent content = LegalDocContent(
      title: 'Privacy Policy',
      body: 'We respect your privacy...',
    );

    test('getters return constructor values', () {
      expect(content.title, 'Privacy Policy');
      expect(content.body, 'We respect your privacy...');
    });

    test('defaults to empty strings', () {
      const LegalDocContent empty = LegalDocContent();
      expect(empty.title, '');
      expect(empty.body, '');
    });

    test('two instances with same fields are equal', () {
      const LegalDocContent other = LegalDocContent(
        title: 'Privacy Policy',
        body: 'We respect your privacy...',
      );
      expect(content, equals(other));
      expect(content.hashCode, equals(other.hashCode));
    });

    test('instances with different body are not equal', () {
      const LegalDocContent other = LegalDocContent(
        title: 'Privacy Policy',
        body: 'Different body.',
      );
      expect(content, isNot(equals(other)));
    });
  });
}
