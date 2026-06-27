import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/me/entity/seller_stats.dart';

void main() {
  group('SellerStat', () {
    const SellerStat stat = SellerStat(label: 'Sales', value: '42');

    test('getters return constructor values', () {
      expect(stat.label, 'Sales');
      expect(stat.value, '42');
    });

    test('two instances with same fields are equal', () {
      const SellerStat other = SellerStat(label: 'Sales', value: '42');
      expect(stat, equals(other));
      expect(stat.hashCode, equals(other.hashCode));
    });

    test('instances with different label are not equal', () {
      const SellerStat other = SellerStat(label: 'Revenue', value: '42');
      expect(stat, isNot(equals(other)));
    });
  });

  group('SellerStats', () {
    const SellerStat s1 = SellerStat(label: 'Sales', value: '42');
    const SellerStat s2 = SellerStat(label: 'Rating', value: '4.8');
    const SellerStats stats = SellerStats(entries: <SellerStat>[s1, s2]);

    test('entries getter returns the list', () {
      expect(stats.entries, <SellerStat>[s1, s2]);
    });

    test('default entries is empty', () {
      const SellerStats empty = SellerStats();
      expect(empty.entries, isEmpty);
    });

    test('two instances with same entries are equal', () {
      const SellerStats other = SellerStats(entries: <SellerStat>[s1, s2]);
      expect(stats, equals(other));
      expect(stats.hashCode, equals(other.hashCode));
    });

    test('instances with different entries are not equal', () {
      const SellerStats other = SellerStats();
      expect(stats, isNot(equals(other)));
    });
  });
}
