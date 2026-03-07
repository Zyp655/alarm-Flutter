import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final int id;
  final int courseId;
  final int userId;
  final String userName;
  final String? userAvatar;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final String? teacherResponse;
  final DateTime? responseDate;
  final int helpfulCount;

  const ReviewEntity({
    required this.id,
    required this.courseId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.teacherResponse,
    this.responseDate,
    this.helpfulCount = 0,
  });

  @override
  List<Object?> get props => [
    id,
    courseId,
    userId,
    rating,
    comment,
    createdAt,
    teacherResponse,
    helpfulCount,
  ];
}
