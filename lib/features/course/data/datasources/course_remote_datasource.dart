import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/api/api_constants.dart';
import '../models/course_model.dart';
import '../models/enrollment_model.dart';
import '../models/module_model.dart';
import '../models/comment_model.dart';
import '../models/submission_model.dart';
import '../models/course_student_model.dart';
import '../models/lesson_model.dart';
import '../../domain/entities/lesson_entity.dart';

class AlreadyEnrolledException implements Exception {
  final String message;
  AlreadyEnrolledException(this.message);

  @override
  String toString() => message;
}

abstract class CourseRemoteDataSource {
  Future<List<CourseModel>> getCourses({
    String? search,
    String? level,
    int? instructorId,
    int? majorId,
    bool showUnpublished = false,
  });

  Future<CourseModel> getCourseDetails(int courseId, {int? userId});
  Future<List<ModuleModel>> getCourseCurriculum(int courseId);
  Future<CourseModel> createCourse(Map<String, dynamic> courseData);
  Future<void> updateCourse(int courseId, Map<String, dynamic> updates);
  Future<void> deleteCourse(int courseId);
  Future<ModuleModel> createModule(Map<String, dynamic> data);
  Future<LessonModel> createLesson(Map<String, dynamic> data);
  Future<void> updateLesson(int lessonId, Map<String, dynamic> updates);
  Future<void> deleteLesson(int lessonId);
  Future<EnrollmentModel> enrollCourse(int userId, int courseId);
  Future<List<EnrollmentModel>> getMyEnrollments(int userId);
  Future<void> updateLessonProgress({
    required int userId,
    required int lessonId,
    int lastWatchedPosition = 0,
    bool isCompleted = false,
  });

  Future<List<CommentModel>> getComments(int lessonId);
  Future<void> createComment(Map<String, dynamic> data);
  Future<void> createSubmission(Map<String, dynamic> data);
  Future<List<SubmissionModel>> getSubmissions(int assignmentId);
  Future<List<CourseStudentModel>> getCourseStudents(int courseId);
}

class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  final http.Client client;

  CourseRemoteDataSourceImpl({required this.client});

  @override
  Future<List<CourseModel>> getCourses({
    String? search,
    String? level,
    int? instructorId,
    int? majorId,
    bool showUnpublished = false,
  }) async {
    final queryParams = <String, String>{};
    if (search != null) queryParams['search'] = search;
    if (level != null) queryParams['level'] = level;
    if (instructorId != null) {
      queryParams['instructorId'] = instructorId.toString();
    }
    if (majorId != null) queryParams['majorId'] = majorId.toString();
    if (showUnpublished) queryParams['showUnpublished'] = 'true';

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/courses',
    ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final courses = data['courses'] as List;
      return courses
          .map(
            (courseJson) =>
                CourseModel.fromJson(courseJson as Map<String, dynamic>),
          )
          .toList();
    } else {
      throw Exception(
        'Không thể tải danh sách khóa học. Vui lòng thử lại sau.',
      );
    }
  }

  @override
  Future<CourseModel> getCourseDetails(int courseId, {int? userId}) async {
    String url = '${ApiConstants.baseUrl}/courses/$courseId';
    if (userId != null) {
      url += '?userId=$userId';
    }
    final response = await client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return CourseModel.fromJson(data);
    } else {
      throw Exception(
        'Không thể tải thông tin khóa học. Vui lòng thử lại sau.',
      );
    }
  }

  @override
  Future<List<ModuleModel>> getCourseCurriculum(int courseId) async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/courses/$courseId'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final modules = data['modules'] as List;
      return modules
          .map(
            (moduleJson) =>
                ModuleModel.fromJson(moduleJson as Map<String, dynamic>),
          )
          .toList();
    } else {
      throw Exception('Không thể tải nội dung khóa học. Vui lòng thử lại sau.');
    }
  }

  @override
  Future<CourseModel> createCourse(Map<String, dynamic> courseData) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/courses'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(courseData),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return CourseModel.fromJson(data['course'] as Map<String, dynamic>);
    } else {
      throw Exception('Không thể tạo khóa học. Vui lòng thử lại sau.');
    }
  }

  @override
  Future<void> updateCourse(int courseId, Map<String, dynamic> updates) async {
    final response = await client.put(
      Uri.parse('${ApiConstants.baseUrl}/courses/$courseId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updates),
    );

    if (response.statusCode != 200) {
      throw Exception('Không thể cập nhật khóa học. Vui lòng thử lại sau.');
    }
  }

  @override
  Future<void> deleteCourse(int courseId) async {
    final response = await client.delete(
      Uri.parse('${ApiConstants.baseUrl}/courses/$courseId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Không thể xóa khóa học. Vui lòng thử lại sau.');
    }
  }

  @override
  Future<ModuleModel> createModule(Map<String, dynamic> data) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/modules'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
     
      final responseData = json.decode(response.body);
      return ModuleModel(
        id: responseData['id'],
        courseId: data['courseId'],
        title: data['title'],
        description: data['description'],
        orderIndex: 0,
        lessons: [],
        createdAt: DateTime.now(),
      );
    } else {
      throw Exception('Không thể tạo chương. Vui lòng thử lại sau.');
    }
  }

  @override
  Future<LessonModel> createLesson(Map<String, dynamic> data) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/lessons'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      return LessonModel(
        id: responseData['id'],
        moduleId: data['moduleId'],
        title: data['title'],
        type: _parseLessonType(data['type']),
        contentUrl: data['contentUrl'],
        durationMinutes: data['durationMinutes'] ?? 0,
        isFreePreview: data['isFreePreview'] ?? false,
        orderIndex: 0,
        createdAt: DateTime.now(),
      );
    } else {
      throw Exception('Không thể tạo bài học. Vui lòng thử lại sau.');
    }
  }

  @override
  Future<void> updateLesson(int lessonId, Map<String, dynamic> updates) async {
    final response = await client.put(
      Uri.parse('${ApiConstants.baseUrl}/lessons/$lessonId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updates),
    );

    if (response.statusCode != 200) {
      throw Exception('Không thể cập nhật bài học. Vui lòng thử lại sau.');
    }
  }

  @override
  Future<void> deleteLesson(int lessonId) async {
    final response = await client.delete(
      Uri.parse('${ApiConstants.baseUrl}/lessons/$lessonId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Không thể xóa bài học. Vui lòng thử lại sau.');
    }
  }

  LessonType _parseLessonType(String? type) {
    if (type == 'video') return LessonType.video;
    if (type == 'document') return LessonType.text; 
    if (type == 'quiz') return LessonType.quiz;
    if (type == 'assignment') return LessonType.assignment;
    return LessonType.video;
  }

  @override
  Future<EnrollmentModel> enrollCourse(int userId, int courseId) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}/enrollments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId, 'courseId': courseId}),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return EnrollmentModel.fromJson(
          data['enrollment'] as Map<String, dynamic>,
        );
      } else if (response.statusCode == 409) {
        throw AlreadyEnrolledException(
          'Bạn đã đăng ký khóa học này rồi. Vui lòng vào "Khóa học của tôi" để tiếp tục học.',
        );
      } else if (response.statusCode == 404) {
        throw Exception('Khóa học không tồn tại.');
      } else {
        throw Exception('Không thể đăng ký khóa học. Vui lòng thử lại sau.');
      }
    } catch (e) {
      if (e is AlreadyEnrolledException) {
        rethrow;
      }
      throw Exception('Không thể đăng ký khóa học: ${e.toString()}');
    }
  }

  @override
  Future<List<EnrollmentModel>> getMyEnrollments(int userId) async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/enrollments?userId=$userId'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final enrollments = data['enrollments'] as List;
      return enrollments
          .map(
            (enrollmentJson) => EnrollmentModel.fromJson(
              enrollmentJson as Map<String, dynamic>,
            ),
          )
          .toList();
    } else {
      throw Exception('Không thể tải khóa học của bạn. Vui lòng thử lại sau.');
    }
  }

  @override
  Future<void> updateLessonProgress({
    required int userId,
    required int lessonId,
    int lastWatchedPosition = 0,
    bool isCompleted = false,
  }) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/lessons/$lessonId/progress'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId,
        'lastWatchedPosition': lastWatchedPosition,
        'isCompleted': isCompleted,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Không thể cập nhật tiến độ. Vui lòng thử lại sau.');
    }
  }

  @override
  Future<List<CommentModel>> getComments(int lessonId) async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/comments?lessonId=$lessonId'),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => CommentModel.fromJson(e)).toList();
    } else {
      throw Exception('Không thể tải bình luận. Vui lòng thử lại sau.');
    }
  }

  @override
  Future<void> createComment(Map<String, dynamic> data) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/comments'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 201) {
      throw Exception('Không thể gửi bình luận. Vui lòng thử lại sau.');
    }
  }

  @override
  Future<void> createSubmission(Map<String, dynamic> data) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/submissions'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 201) {
      throw Exception('Không thể nộp bài. Vui lòng thử lại sau.');
    }
  }

  @override
  Future<List<SubmissionModel>> getSubmissions(int assignmentId) async {
    final response = await client.get(
      Uri.parse(
        '${ApiConstants.baseUrl}/submissions?assignmentId=$assignmentId',
      ),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => SubmissionModel.fromJson(e)).toList();
    } else {
      throw Exception('Không thể tải danh sách bài nộp. Vui lòng thử lại sau.');
    }
  }

  @override
  Future<List<CourseStudentModel>> getCourseStudents(int courseId) async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/courses/$courseId/students'),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => CourseStudentModel.fromJson(e)).toList();
    } else {
      throw Exception(
        'Không thể tải danh sách học viên. Vui lòng thử lại sau.',
      );
    }
  }
}
