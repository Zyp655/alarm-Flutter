import '../../../../core/api/api_client.dart';
import '../models/schedule_model.dart';

abstract class ScheduleRemoteDataSource {
  Future<List<ScheduleModel>> getSchedules();
  Future<void> addSchedule(List<ScheduleModel> schedules);
  Future<void> deleteSchedule(int id);
  Future<void> updateSchedule(ScheduleModel schedule);
  Future<void> joinClass(String code);
}

class ScheduleRemoteDataSourceImpl implements ScheduleRemoteDataSource {
  final ApiClient apiClient;

  ScheduleRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<ScheduleModel>> getSchedules() async {
    final response = await apiClient.get('/schedule');
    return (response as List).map((e) => ScheduleModel.fromJson(e)).toList();
  }

  @override
  Future<void> addSchedule(List<ScheduleModel> schedules) async {
    if (schedules.length == 1) {
      await apiClient.post('/schedule', schedules.first.toJson());
    } else {
      final body = schedules.map((e) => e.toJson()).toList();
      await apiClient.post('/schedule', body);
    }
  }

  @override
  Future<void> deleteSchedule(int id) async {
    await apiClient.delete('/schedule/$id');
  }

  @override
  Future<void> updateSchedule(ScheduleModel schedule) async {
    await apiClient.put('/schedule/${schedule.id}', schedule.toJson());
  }

  @override
  Future<void> joinClass(String code) async {
    await apiClient.post(
      '/student/join_class',
      {'code': code},
    );
  }
}