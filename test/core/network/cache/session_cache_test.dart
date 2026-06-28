import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/core/network/cache/session_cache.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

Response<dynamic> _makeResponse({
  String path = '/test',
  dynamic data = 'cached',
}) => Response<dynamic>(
  requestOptions: RequestOptions(path: path),
  statusCode: 200,
  data: data,
);

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late SessionCache cache;

  setUp(() {
    cache = SessionCache();
  });

  // ── get ─────────────────────────────────────────────────────────────────────

  group('get', () {
    test('returns null for an unknown key', () {
      expect(cache.get('/unknown'), isNull);
    });
  });

  // ── put / get ────────────────────────────────────────────────────────────────

  group('put / get', () {
    test('stores and retrieves a response by key', () {
      final response = _makeResponse();
      cache.put('/test', response);
      expect(cache.get('/test'), same(response));
    });

    test('overwrites an existing entry with the same key', () {
      final first = _makeResponse(data: 'first');
      final second = _makeResponse(data: 'second');
      cache.put('/test', first);
      cache.put('/test', second);
      expect(cache.get('/test'), same(second));
    });

    test('stores response without a group (no group tracking)', () {
      final response = _makeResponse(path: '/ungrouped');
      cache.put('/ungrouped', response);
      expect(cache.get('/ungrouped'), same(response));
    });

    test('stores multiple keys independently', () {
      final r1 = _makeResponse(path: '/a');
      final r2 = _makeResponse(path: '/b');
      cache.put('/a', r1);
      cache.put('/b', r2);
      expect(cache.get('/a'), same(r1));
      expect(cache.get('/b'), same(r2));
    });
  });

  // ── invalidateGroup ──────────────────────────────────────────────────────────

  group('invalidateGroup', () {
    test('removes all keys belonging to the group', () {
      cache.put('/a', _makeResponse(path: '/a'), group: 'g1');
      cache.put('/b', _makeResponse(path: '/b'), group: 'g1');
      cache.put('/c', _makeResponse(path: '/c'), group: 'g2');

      cache.invalidateGroup('g1');

      expect(cache.get('/a'), isNull);
      expect(cache.get('/b'), isNull);
      expect(cache.get('/c'), isNotNull);
    });

    test('does nothing for an unknown group', () {
      cache.put('/d', _makeResponse(path: '/d'), group: 'g3');
      cache.invalidateGroup('nonexistent');
      expect(cache.get('/d'), isNotNull);
    });

    test('can invalidate the same group a second time without error', () {
      cache.put('/e', _makeResponse(path: '/e'), group: 'g4');
      cache.invalidateGroup('g4');
      // Second call on already-removed group must not throw.
      expect(() => cache.invalidateGroup('g4'), returnsNormally);
    });
  });

  // ── clear ────────────────────────────────────────────────────────────────────

  group('clear', () {
    test('wipes all stored entries', () {
      cache.put('/x', _makeResponse(path: '/x'), group: 'gx');
      cache.put('/y', _makeResponse(path: '/y'), group: 'gy');
      cache.clear();
      expect(cache.get('/x'), isNull);
      expect(cache.get('/y'), isNull);
    });

    test('allows new entries to be stored after clear', () {
      cache.put('/z', _makeResponse(path: '/z'));
      cache.clear();
      final fresh = _makeResponse(path: '/z', data: 'new');
      cache.put('/z', fresh);
      expect(cache.get('/z'), same(fresh));
    });
  });

  // ── cacheable helper ─────────────────────────────────────────────────────────

  group('cacheable', () {
    test('returns Options with kCacheFlag set to true', () {
      final opts = cacheable('group_a');
      expect(opts.extra?[kCacheFlag], isTrue);
    });

    test('returns Options with kCacheGroup set to the supplied group name', () {
      final opts = cacheable('group_b');
      expect(opts.extra?[kCacheGroup], 'group_b');
    });
  });

  // ── constants ────────────────────────────────────────────────────────────────

  group('constants', () {
    test('kCacheFlag equals "session_cache"', () {
      expect(kCacheFlag, 'session_cache');
    });

    test('kCacheGroup equals "session_cache_group"', () {
      expect(kCacheGroup, 'session_cache_group');
    });
  });
}
