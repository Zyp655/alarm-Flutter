class ProfileModel {
  final String fullName;
  final String studentId;
  final String major;
  final String? avatarUrl;

  ProfileModel({
    required this.fullName,
    required this.studentId,
    required this.major,
    this.avatarUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      fullName: json['fullName'] ?? '',
      studentId: json['studentId'] ?? '',
      major: json['major'] ?? '',
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'studentId': studentId,
    'major': major,
  };
}