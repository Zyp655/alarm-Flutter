import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:backend/helpers/pagination.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  final db = context.read<AppDatabase>();

  switch (context.request.method) {
    case HttpMethod.get:
      return _getReviews(context, db);
    case HttpMethod.post:
      return _submitReview(context, db);
    case HttpMethod.put:
      return _respondToReview(context, db);
    case HttpMethod.patch:
      return _markHelpful(context, db);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _getReviews(RequestContext context, AppDatabase db) async {
  final courseId =
      int.tryParse(context.request.uri.queryParameters['courseId'] ?? '');

  if (courseId == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'courseId is required'},
    );
  }

  try {
    final query = db.select(db.courseReviews).join([
      innerJoin(db.users, db.users.id.equalsExp(db.courseReviews.userId)),
    ]);
    query.where(db.courseReviews.courseId.equals(courseId));
    query.orderBy([OrderingTerm.desc(db.courseReviews.createdAt)]);

    final pg = Pagination.fromQuery(context.request.uri.queryParameters);

    final rows = await query.get();

    final allReviews = <Map<String, dynamic>>[];
    final distribution = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    double totalRating = 0;

    for (final row in rows) {
      final review = row.readTable(db.courseReviews);
      final user = row.readTable(db.users);

      distribution[review.rating] = (distribution[review.rating] ?? 0) + 1;
      totalRating += review.rating;

      allReviews.add({
        'id': review.id,
        'courseId': review.courseId,
        'userId': review.userId,
        'userName': user.fullName ?? user.email,
        'rating': review.rating,
        'comment': review.comment,
        'createdAt': review.createdAt.toIso8601String(),
        'teacherResponse': review.teacherResponse,
        'responseDate': review.responseDate?.toIso8601String(),
        'helpfulCount': review.helpfulCount,
      });
    }

    final avgRating =
        allReviews.isNotEmpty ? totalRating / allReviews.length : 0.0;
    final total = allReviews.length;

    final paginatedReviews = allReviews.skip(pg.offset).take(pg.limit).toList();

    return Response.json(body: {
      ...pg.wrap(paginatedReviews, total: total, key: 'reviews'),
      'averageRating': double.parse(avgRating.toStringAsFixed(1)),
      'totalReviews': total,
      'distribution': distribution,
    });
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'},
    );
  }
}

Future<Response> _submitReview(RequestContext context, AppDatabase db) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final courseId = body['courseId'] as int?;
    final userId = body['userId'] as int?;
    final rating = body['rating'] as int?;
    final comment = body['comment'] as String?;

    if (courseId == null || userId == null || rating == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'courseId, userId, rating are required'},
      );
    }

    if (rating < 1 || rating > 5) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Rating must be 1-5'},
      );
    }

    final existing = await (db.select(db.courseReviews)
          ..where((r) => r.courseId.equals(courseId) & r.userId.equals(userId)))
        .getSingleOrNull();

    if (existing != null) {

      await (db.update(db.courseReviews)
            ..where((r) => r.id.equals(existing.id)))
          .write(CourseReviewsCompanion(
        rating: Value(rating),
        comment: Value(comment),
        updatedAt: Value(DateTime.now()),
      ));
      return Response.json(body: {
        'id': existing.id,
        'message': 'Review updated',
      });
    }

    final id = await db.into(db.courseReviews).insert(
          CourseReviewsCompanion.insert(
            courseId: courseId,
            userId: userId,
            rating: rating,
            comment: Value(comment),
            createdAt: DateTime.now(),
          ),
        );

    return Response.json(
      statusCode: HttpStatus.created,
      body: {'id': id, 'message': 'Review submitted'},
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'},
    );
  }
}

Future<Response> _respondToReview(
    RequestContext context, AppDatabase db) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final reviewId = body['reviewId'] as int?;
    final response = body['response'] as String?;

    if (reviewId == null || response == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'reviewId and response are required'},
      );
    }

    await (db.update(db.courseReviews)..where((r) => r.id.equals(reviewId)))
        .write(CourseReviewsCompanion(
      teacherResponse: Value(response),
      responseDate: Value(DateTime.now()),
    ));

    return Response.json(body: {'message': 'Response saved'});
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'},
    );
  }
}

Future<Response> _markHelpful(RequestContext context, AppDatabase db) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final reviewId = body['reviewId'] as int?;

    if (reviewId == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'reviewId is required'},
      );
    }

    final review = await (db.select(db.courseReviews)
          ..where((r) => r.id.equals(reviewId)))
        .getSingleOrNull();

    if (review == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Review not found'},
      );
    }

    await (db.update(db.courseReviews)..where((r) => r.id.equals(reviewId)))
        .write(CourseReviewsCompanion(
      helpfulCount: Value(review.helpfulCount + 1),
    ));

    return Response.json(body: {
      'message': 'Marked as helpful',
      'helpfulCount': review.helpfulCount + 1,
    });
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'},
    );
  }
}
