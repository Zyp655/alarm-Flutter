import 'package:equatable/equatable.dart';

abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadLeaderboard extends LeaderboardEvent {
  final int classId;
  final String period;

  const LoadLeaderboard({required this.classId, this.period = 'all_time'});

  @override
  List<Object?> get props => [classId, period];
}
