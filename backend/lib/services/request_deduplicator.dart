import 'dart:async';
import 'dart:convert';
import 'package:backend/services/redis_service.dart';

class RequestDeduplicator {
  static final RequestDeduplicator _instance = RequestDeduplicator._internal();
  factory RequestDeduplicator() => _instance;
  RequestDeduplicator._internal();

  final _inflightRequests = <String, Future<dynamic>>{};
  final _redis = RedisService();

  String _hashKey(String prefix, Map<String, dynamic> params) {
    final sorted = Map.fromEntries(
      params.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    final raw = '$prefix:${jsonEncode(sorted)}';
    var hash = 0x811c9dc5;
    for (var i = 0; i < raw.length; i++) {
      hash ^= raw.codeUnitAt(i);
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return 'dedup:$prefix:${hash.toRadixString(16)}';
  }

  Future<T> deduplicate<T>({
    required String category,
    required Map<String, dynamic> params,
    required Future<T> Function() execute,
    int cacheTtlSeconds = 60,
  }) async {
    final key = _hashKey(category, params);

    if (_inflightRequests.containsKey(key)) {
      return await _inflightRequests[key]! as T;
    }

    if (_redis.isConnected && T == Map<String, dynamic>) {
      final cached = await _redis.getJson(key);
      if (cached != null) return cached as T;
    }

    final completer = Completer<T>();
    _inflightRequests[key] = completer.future;

    try {
      final result = await execute();

      if (_redis.isConnected && result is Map<String, dynamic>) {
        await _redis.setJson(key, result, ttlSeconds: cacheTtlSeconds);
      }

      completer.complete(result);
      return result;
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _inflightRequests.remove(key);
    }
  }

  int get inflightCount => _inflightRequests.length;

  void clearAll() => _inflightRequests.clear();
}
