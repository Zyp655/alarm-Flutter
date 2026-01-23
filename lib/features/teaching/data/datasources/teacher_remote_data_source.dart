import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/api/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../schedule/data/models/schedule_model.dart';
import '../../../schedule/domain/enitities/schedule_entity.dart';
import '../../domain/entities/subject_entity.dart';
import '../models/assignment_model.dart';

abstract class TeacherRemoteDataSource {
  Future<List<AssignmentModel>> getAssignments(int teacherId);

  Future<void> createAssignment(AssignmentModel assignment, int teacherId);

  Future<void> updateAssignment(AssignmentModel assignment, int teacherId);

  Future<void> deleteAssignment(int assignmentId, int teacherId);

  Future<void> createClass(
    String className,
    int teacherId,
    String subjectName,
    String room,
    DateTime startTime,
    DateTime endTime,
    DateTime startDate,
    int repeatWeeks,
    int notificationMinutes,
    int credits,
  );

  Future<void> createSubject(
    int teacherId,
    String name,
    int credits,
    String? code,
  );

  Future<List<ScheduleEntity>> getAllSchedules(int teacherId);

  Future<String> regenerateClassCode(
    int teacherId,
    String subjectName,
    bool isRefresh,
  );

  Future<List<SubjectEntity>> getSubjects(int teacherId);

  Future<void> updateScore(
    int scheduleId,
    int? absences,
    double? midtermScore,
    double? finalScore,
  );

  Future<void> importSchedules(
    int teacherId,
    List<Map<String, dynamic>> schedules,
  );

  Future<List<Map<String, dynamic>>> getStudentsInClass(int classId);
}

class TeacherRemoteDataSourceImpl implements TeacherRemoteDataSource {
  final http.Client client;

  TeacherRemoteDataSourceImpl({required this.client});

  @override
  Future<List<SubjectEntity>> getSubjects(int teacherId) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}/teacher/subjects?teacherId=$teacherId',
    );
    final response = await client.get(url);

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);
      return decoded
          .map(
            (e) => SubjectEntity(
              id: e['id'],
              name: e['name'],
              code: e['code'],
              credits: e['credits'] ?? 3,
            ),
          )
          .toList();
    } else {
      throw ServerException("Lỗi tải danh sách môn: ${response.statusCode}");
    }
  }

  @override
  Future<void> createSubject(
    int teacherId,
    String name,
    int credits,
    String? code,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/teacher/subjects');
    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'teacherId': teacherId,
        'name': name,
        'credits': credits,
        'code': code,
      }),
    );

    if (response.statusCode != 200) {
      throw ServerException("Lỗi tạo môn: ${response.body}");
    }
  }

  @override
  Future<void> createClass(
    String className,
    int teacherId,
    String subjectName,
    String room,
    DateTime startTime,
    DateTime endTime,
    DateTime startDate,
    int repeatWeeks,
    int notificationMinutes,
    int credits,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/teacher/create_class');
    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'className': className,
        'teacherId': teacherId,
        'subjectName': subjectName,
        'room': room,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'startDate': startDate.toIso8601String(),
        'repeatWeeks': repeatWeeks,
        'notificationMinutes': notificationMinutes,
        'credits': credits,
      }),
    );

    if (response.statusCode != 200) {
      throw ServerException("Lỗi tạo lớp: ${response.body}");
    }
  }

  @override
  Future<List<ScheduleEntity>> getAllSchedules(int teacherId) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}/teacher/schedules?userId=$teacherId',
    );
    final response = await client.get(url);

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);
      return decoded.map((e) => ScheduleModel.fromJson(e)).toList();
    } else {
      throw ServerException("Lỗi server: ${response.statusCode}");
    }
  }

  @override
  Future<void> updateScore(
    int scheduleId,
    int? absences,
    double? midtermScore,
    double? finalScore,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/teacher/update_score');

    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'schedule_id': scheduleId,
        'absences': absences,
        'midtermScore': midtermScore,
        'finalScore': finalScore,
      }),
    );

    if (response.statusCode != 200) {
      throw ServerException("Lỗi cập nhật điểm: ${response.body}");
    }
  }

  @override
  Future<void> importSchedules(
    int teacherId,
    List<Map<String, dynamic>> schedules,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/teacher/import_schedule');

    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'teacherId': teacherId, 'schedules': schedules}),
    );

    if (response.statusCode != 200) {
      throw ServerException("Lỗi import: ${response.body}");
    }
  }

  @override
  Future<String> regenerateClassCode(
    int teacherId,
    String subjectName,
    bool isRefresh,
  ) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/teacher/regenerate_code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'teacherId': teacherId,
        'subjectName': subjectName,
        'forceRefresh': isRefresh,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['newCode'];
    } else {
      throw Exception('error: ${response.body}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getStudentsInClass(int classId) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}/teacher/classes/$classId/students',
    );
    final response = await client.get(url);

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);
      return decoded.cast<Map<String, dynamic>>();
    } else {
      throw ServerException(
        "Lỗi tải danh sách sinh viên: ${response.statusCode}",
      );
    }
  }

  @override
  Future<List<AssignmentModel>> getAssignments(int teacherId) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}/teacher/assignments?userId=$teacherId',
    );
    final response = await client.get(url);

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);
      return decoded.map((e) => AssignmentModel.fromJson(e)).toList();
    } else {
      throw ServerException(
        "Lỗi tải danh sách bài tập: ${response.statusCode}",
      );
    }
  }

  @override
  Future<void> createAssignment(
    AssignmentModel assignment,
    int teacherId,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/teacher/assignments/create');

    final body = assignment.toJson();
    body['teacherId'] = teacherId;

    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw ServerException("Lỗi tạo bài tập: ${response.body}");
    }
  }

  @override
  Future<void> updateAssignment(
    AssignmentModel assignment,
    int teacherId,
  ) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}/teacher/assignments/${assignment.id}/update',
    );

    final body = assignment.toJson();
    body['teacherId'] = teacherId;

    final response = await client.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw ServerException("Lỗi cập nhật bài tập: ${response.body}");
    }
  }

  @override
  Future<void> deleteAssignment(int assignmentId, int teacherId) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}/teacher/assignments/$assignmentId/delete?teacherId=$teacherId',
    );

    final response = await client.delete(url);

    if (response.statusCode != 200) {
      throw ServerException("Lỗi xóa bài tập: ${response.body}");
    }
  }
}
