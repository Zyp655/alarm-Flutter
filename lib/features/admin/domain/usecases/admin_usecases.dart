import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/admin_repository.dart';

class GetUsersUseCase {
  final AdminRepository repository;
  GetUsersUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    int? role,
    String? search,
    int? departmentId,
    String? studentClass,
  }) {
    return repository.getUsers(
      role: role,
      search: search,
      departmentId: departmentId,
      studentClass: studentClass,
    );
  }
}

class UpdateUserUseCase {
  final AdminRepository repository;
  UpdateUserUseCase(this.repository);

  Future<Either<Failure, String>> call(int userId, Map<String, dynamic> data) {
    return repository.updateUser(userId, data);
  }
}

class DeleteUserUseCase {
  final AdminRepository repository;
  DeleteUserUseCase(this.repository);

  Future<Either<Failure, String>> call(int userId) {
    return repository.deleteUser(userId);
  }
}

class ToggleBanUseCase {
  final AdminRepository repository;
  ToggleBanUseCase(this.repository);

  Future<Either<Failure, String>> call(int userId) {
    return repository.toggleBan(userId);
  }
}

class GetAdminCoursesUseCase {
  final AdminRepository repository;
  GetAdminCoursesUseCase(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call({String? search}) {
    return repository.getAdminCourses(search: search);
  }
}

class TogglePublishUseCase {
  final AdminRepository repository;
  TogglePublishUseCase(this.repository);

  Future<Either<Failure, String>> call(int courseId, bool current) {
    return repository.togglePublish(courseId, current);
  }
}

class DeleteCourseUseCase {
  final AdminRepository repository;
  DeleteCourseUseCase(this.repository);

  Future<Either<Failure, String>> call(int courseId) {
    return repository.deleteCourse(courseId);
  }
}

class GetAnalyticsUseCase {
  final AdminRepository repository;
  GetAnalyticsUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call() {
    return repository.getAnalytics();
  }
}

class GetAcademicDataUseCase {
  final AdminRepository repository;
  GetAcademicDataUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call() {
    return repository.getAcademicData();
  }
}

class SeedUsersUseCase {
  final AdminRepository repository;
  SeedUsersUseCase(this.repository);

  Future<Either<Failure, String>> call() => repository.seedUsers();
}

class SeedAchievementsUseCase {
  final AdminRepository repository;
  SeedAchievementsUseCase(this.repository);

  Future<Either<Failure, String>> call() => repository.seedAchievements();
}

class SeedRoadmapUseCase {
  final AdminRepository repository;
  SeedRoadmapUseCase(this.repository);

  Future<Either<Failure, String>> call() => repository.seedRoadmap();
}

class AssignRoadmapTeacherUseCase {
  final AdminRepository repository;
  AssignRoadmapTeacherUseCase(this.repository);

  Future<Either<Failure, String>> call(String email) {
    return repository.assignRoadmapTeacher(email);
  }
}

class ImportStudentsUseCase {
  final AdminRepository repository;
  ImportStudentsUseCase(this.repository);

  Future<Either<Failure, String>> call(Map<String, dynamic> payload) {
    return repository.importStudents(payload);
  }
}

class ImportTeachersUseCase {
  final AdminRepository repository;
  ImportTeachersUseCase(this.repository);

  Future<Either<Failure, String>> call(Map<String, dynamic> payload) {
    return repository.importTeachers(payload);
  }
}

class GetAcademicCoursesWithTeachersUseCase {
  final AdminRepository repository;
  GetAcademicCoursesWithTeachersUseCase(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call() {
    return repository.getAcademicCoursesWithTeachers();
  }
}

class CreateCourseClassUseCase {
  final AdminRepository repository;
  CreateCourseClassUseCase(this.repository);

  Future<Either<Failure, String>> call(
    int academicCourseId,
    String classCode, {
    String? room,
    String? schedule,
    int? maxStudents,
  }) {
    return repository.createCourseClass(
      academicCourseId,
      classCode,
      room: room,
      schedule: schedule,
      maxStudents: maxStudents,
    );
  }
}

class AssignCourseTeacherUseCase {
  final AdminRepository repository;
  AssignCourseTeacherUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
    int courseClassId,
    int teacherId, {
    bool force = false,
  }) {
    return repository.assignCourseTeacher(
      courseClassId,
      teacherId,
      force: force,
    );
  }
}

class UnassignCourseTeacherUseCase {
  final AdminRepository repository;
  UnassignCourseTeacherUseCase(this.repository);

  Future<Either<Failure, String>> call(int courseClassId) {
    return repository.unassignCourseTeacher(courseClassId);
  }
}
