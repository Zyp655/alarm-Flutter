import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    int? id,
    required String title,
    String? description,
    required DateTime dueDate,
    bool isCompleted = false,
    required int userId,
  }) : super(
         id: id,
         title: title,
         description: description,
         dueDate: dueDate,
         isCompleted: isCompleted,
         userId: userId,
       );

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      isCompleted: json['isCompleted'] ?? false,
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'userId': userId,
    };
  }
}
