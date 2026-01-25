import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    super.id,
    required super.userId,
    required super.type,
    required super.title,
    required super.message,
    super.isRead,
    super.actionUrl,
    super.relatedId,
    super.relatedType,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int?,
      userId: json['userId'] as int,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      isRead: json['isRead'] as bool? ?? false,
      actionUrl: json['actionUrl'] as String?,
      relatedId: json['relatedId'] as int?,
      relatedType: json['relatedType'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      'isRead': isRead,
      'actionUrl': actionUrl,
      'relatedId': relatedId,
      'relatedType': relatedType,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      userId: entity.userId,
      type: entity.type,
      title: entity.title,
      message: entity.message,
      isRead: entity.isRead,
      actionUrl: entity.actionUrl,
      relatedId: entity.relatedId,
      relatedType: entity.relatedType,
      createdAt: entity.createdAt,
    );
  }
}
