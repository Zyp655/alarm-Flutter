import 'dart:convert';
import 'package:backend/services/redis_service.dart';
import '../database/database.dart';
import 'package:drift/drift.dart';

class CacheService {
  final AppDatabase db;
  final RedisService _redis = RedisService();
  static const maxCacheSize = 100;
  CacheService(this.db);

  String _generateCacheKey(String topic, String difficulty, int numQuestions) {
    final normalized =
        '${topic.toLowerCase().trim()}_${difficulty}_$numQuestions';
    return 'quiz:${normalized.replaceAll(RegExp(r'[^a-z0-9_]'), '')}';
  }

  String _hashKey(String raw) {
    var hash = 0x811c9dc5;
    for (var i = 0; i < raw.length; i++) {
      hash ^= raw.codeUnitAt(i);
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  Future<Map<String, dynamic>?> getCachedQuiz(
    String topic,
    String difficulty,
    int numQuestions,
  ) async {
    final key = _generateCacheKey(topic, difficulty, numQuestions);

    if (_redis.isConnected) {
      final cached = await _redis.getJson(key);
      if (cached != null) return cached;
    }

    final cached = await (db.select(db.quizCache)
          ..where((t) => t.cacheKey.equals(key)))
        .getSingleOrNull();
    if (cached == null) return null;
    await (db.update(db.quizCache)..where((t) => t.id.equals(cached.id)))
        .write(QuizCacheCompanion(
      hitCount: Value(cached.hitCount + 1),
      lastAccessedAt: Value(DateTime.now()),
    ));

    final data = jsonDecode(cached.quizData) as Map<String, dynamic>;
    await _redis.setJson(key, data, ttlSeconds: 600);
    return data;
  }

  Future<void> cacheQuiz(
    String topic,
    String difficulty,
    int numQuestions,
    Map<String, dynamic> quizData,
  ) async {
    final key = _generateCacheKey(topic, difficulty, numQuestions);

    await _redis.setJson(key, quizData, ttlSeconds: 600);

    final existing = await (db.select(db.quizCache)
          ..where((t) => t.cacheKey.equals(key)))
        .getSingleOrNull();
    if (existing != null) {
      await (db.update(db.quizCache)..where((t) => t.id.equals(existing.id)))
          .write(QuizCacheCompanion(
        quizData: Value(jsonEncode(quizData)),
        lastAccessedAt: Value(DateTime.now()),
      ));
      return;
    }
    final count = await db.quizCache.count().getSingle();
    if (count >= maxCacheSize) {
      await _evictLRU();
    }
    await db.into(db.quizCache).insert(
          QuizCacheCompanion.insert(
            cacheKey: key,
            quizData: jsonEncode(quizData),
            createdAt: DateTime.now(),
            lastAccessedAt: DateTime.now(),
          ),
        );
  }

  Future<void> _evictLRU() async {
    final oldest = await (db.select(db.quizCache)
          ..orderBy([(t) => OrderingTerm.asc(t.lastAccessedAt)])
          ..limit(10))
        .get();
    for (final item in oldest) {
      await (db.delete(db.quizCache)..where((t) => t.id.equals(item.id))).go();
      await _redis.delete(item.cacheKey);
    }
  }

  String _buildRedisKey(String prefix, Map<String, dynamic> params) {
    final paramStr = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return 'ai:$prefix:${_hashKey(paramStr)}';
  }

  Future<Map<String, dynamic>?> getAiCache(
    String prefix,
    Map<String, dynamic> params,
  ) async {
    if (!_redis.isConnected) return null;
    return await _redis.getJson(_buildRedisKey(prefix, params));
  }

  Future<void> setAiCache(
    String prefix,
    Map<String, dynamic> params,
    Map<String, dynamic> data, {
    int ttlSeconds = 300,
  }) async {
    if (!_redis.isConnected) return;
    await _redis.setJson(_buildRedisKey(prefix, params), data, ttlSeconds: ttlSeconds);
  }

  Future<String?> getAiCacheString(
    String prefix,
    Map<String, dynamic> params,
  ) async {
    if (!_redis.isConnected) return null;
    return await _redis.get(_buildRedisKey(prefix, params));
  }

  Future<void> setAiCacheString(
    String prefix,
    Map<String, dynamic> params,
    String data, {
    int ttlSeconds = 300,
  }) async {
    if (!_redis.isConnected) return;
    await _redis.set(_buildRedisKey(prefix, params), data, ttlSeconds: ttlSeconds);
  }

  Future<Map<String, dynamic>> getCacheStats() async {
    final total = await db.quizCache.count().getSingle();
    final allItems = await db.select(db.quizCache).get();
    int totalHits = 0;
    for (final item in allItems) {
      totalHits += item.hitCount;
    }
    return {
      'totalCached': total,
      'totalHits': totalHits,
      'maxSize': maxCacheSize,
      'redisConnected': _redis.isConnected,
    };
  }
}
