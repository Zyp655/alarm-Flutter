import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/api/api_constants.dart';
import '../models/major_model.dart';

abstract class MajorRemoteDataSource {
  Future<List<MajorModel>> getMajors();
}

class MajorRemoteDataSourceImpl implements MajorRemoteDataSource {
  final http.Client client;

  MajorRemoteDataSourceImpl({required this.client});

  @override
  Future<List<MajorModel>> getMajors() async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/majors'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final majors = data['majors'] as List;
      return majors
          .map(
            (majorJson) =>
                MajorModel.fromJson(majorJson as Map<String, dynamic>),
          )
          .toList();
    } else {
      throw Exception(
        'Không thể tải danh sách chuyên ngành. Vui lòng thử lại sau.',
      );
    }
  }
}
