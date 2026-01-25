import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final int? id;
  final int userId;
  final String
  type;
  final String title;
  final String message;
  final bool isRead;
  final String? actionUrl;
  final int? relatedId;
  final String? relatedType; 
  final DateTime createdAt;

  const NotificationEntity({
    this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.isRead = false,
    this.actionUrl,
    this.relatedId,
    this.relatedType,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    title,
    message,
    isRead,
    actionUrl,
    relatedId,
    relatedType,
    createdAt,
  ];
}
