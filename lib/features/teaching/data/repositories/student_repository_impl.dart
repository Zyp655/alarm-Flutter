import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../datasources/student_remote_data_source.dart';
import '../../domain/repositories/student_repository.dart';
import '../../domain/entities/student_assignment_entity.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentRemoteDataSource remoteDataSource;

  StudentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> submitAssignment({
    required int assignmentId,
    required int studentId,
    File? file,
    String? link,
    String? text,
  }) async {
    try {
      await remoteDataSource.submitAssignment(
        assignmentId: assignmentId,
        studentId: studentId,
        file: file,
        link: link,
        text: text,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure("Lỗi không xác định: $e"));
    }
  }

  @override
  Future<Either<Failure, List<StudentAssignmentEntity>>> getStudentAssignments(
    int studentId,
  ) async {
    try {
      final assignments = await remoteDataSource.getStudentAssignments(
        studentId,
      );
      return Right(assignments);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure("Lỗi không xác định: $e"));
    }
  }
}
